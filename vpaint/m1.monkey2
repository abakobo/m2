#Import "<std>"
#Import "<mojo>"

#Import "mojox/mojox.monkey2"

Using std..
Using mojo..

Global instance:AppInstance


Class VPane Extends Image
	Field canvas:Canvas

	Method New(w:Int,h:Int,bg:Color)		
		Super.New(w,h,TextureFlags.Dynamic|TextureFlags.Filter|TextureFlags.Mipmap)		
		canvas=New Canvas(Self)	
		canvas.Clear(bg)
		canvas.Alpha=0.8
	'	fade=New Color(0,1,0,1.0/64)
	End
	
	Method Draw(display:Canvas, zoom:Float)
	
		If fade<>null
			canvas.Color=fade
			canvas.DrawRect(0,0,Width,Height)
		Endif

		canvas.Flush()
		Local z:Float=1.0/zoom
		display.DrawImage( Self, 0,0, 0, z,z)
	End
	
	Method Clear(bg:Color)
		canvas.Clear(bg)
	End
	
	Field fade:Color
	Field segcount:Int
	Field edge0:Vec2f
	Field edge1:Vec2f
	
	Method EndSegment()
		segcount=0
	End

	Method FatSegment(x:Float,y:Float,x1:Float,y1:Float)

		Local fat:Int=6

		If Not canvas Return
				
		Local verts:=New Float[8]
		
		Local dy:Float=y1-y
		Local dx:Float=x1-x
				
		Local len:Float=Sqrt(dx*dx+dy*dy) 
		Local q:Float=fat/len
				
		If segcount=0
			edge0=New Vec2f(x+dy*q,y-dx*q)
			edge1=New Vec2f(x-dy*q,y+dx*q)
		Endif
		segcount+=1
				
		Local v0:=edge0
		Local v1:=New Vec2f(x1+dy*q,y1-dx*q)
		Local v2:=New Vec2f(x1-dy*q,y1+dx*q)
		Local v3:=edge1
				
		canvas.DrawTriangle(v0,v1,v2)
		canvas.DrawTriangle(v0,v2,v3)
				
		edge0=v1
		edge1=v2
	End
	
	
	Method FatCurve(p0:Vec2f,p1:Vec2f,p2:Vec2f,p3:Vec2f)
		If Not canvas Return
		Local seg:Int=16
		Local verts:=New Float[(seg+1)*2]		
		For Local i:Int=0 To seg		
			Local mu:Float=i*1.0/seg			    
'	       	Local x:Float=CubicInterpolate(p0.x,p1.x,p2.x,p3.x,mu)
'        	Local y:Float=CubicInterpolate(p0.y,p1.y,p2.y,p3.y,mu)
        	Local x:Float=CatmullInterpolate(p0.x,p1.x,p2.x,p3.x,mu)
	       	Local y:Float=CatmullInterpolate(p0.y,p1.y,p2.y,p3.y,mu)
          	verts[i*2+0]=x
        	verts[i*2+1]=y
		Next		
		For Local i:Int=0 Until seg		
			FatSegment(verts[i*2+0],verts[i*2+1],verts[i*2+2],verts[i*2+3])
		Next
	End
		
 	Function CubicInterpolate:Float(y0:Float,y1:Float,y2:Float,y3:Float,mu:Float)
		Local a0:Float,a1:Float,a2:Float,a3:Float,mu2:Float
		mu2 = mu*mu
		a0 = y3 - y2 - y0 + y1
		a1 = y0 - y1 - a0
		a2 = y2 - y0
		a3 = y1
		Return(a0*mu*mu2+a1*mu2+a2*mu+a3)
	End
		
 	Function CatmullInterpolate:Float(y0:Float,y1:Float,y2:Float,y3:Float,mu:Float)
		Local a0:Float,a1:Float,a2:Float,a3:Float,mu2:Float	
		mu2 = mu*mu
		a0 = -0.5*y0 + 1.5*y1 - 1.5*y2 + 0.5*y3
		a1 = y0 - 2.5*y1 + 2*y2 - 0.5*y3
		a2 = -0.5*y0 + 0.5*y2
		a3 = y1
		Return(a0*mu*mu2+a1*mu2+a2*mu+a3)
	End
 	 	
 	Function CubicInterpolate2:Float(p0:Float,p1:Float,p2:Float,p3:Float,x:Float)
		Return p1 + 0.5 * x*(p2-p0+x*(2.0*p0-5.0*p1+4.0*p2-p3+x*(3.0*(p1-p2)+p3-p0)))
	End

	Method FatLine(x:Int,y:Int,x1:Int,y1:Int)
		Local fat:Int=7
		If Not canvas Return				
		Local dy:Int=y1-y
		Local dx:Int=x1-x				
		Local len:Float=Sqrt(dx*dx+dy*dy) 
		Local q:Float=fat/len				
		Local v0:=New Vec2f(x+dy*q,y-dx*q)
		Local v1:=New Vec2f(x1+dy*q,y1-dx*q)
		Local v2:=New Vec2f(x1-dy*q,y1+dx*q)
		Local v3:=New Vec2f(x-dy*q,y+dx*q)				
		canvas.DrawTriangle(v0,v1,v2)
		canvas.DrawTriangle(v0,v2,v3)
	End
  
End

Class VPaint Extends Window

	Field pane:VPane
	Field zoom:Float

	Field ink:Color

	Field mousex:Int
	Field mousey:Int
	Field framecount:Int
	Field drawcount:Int

	Method New(title:String)
		Super.New(title,720,560,WindowFlags.Resizable)		
		zoom=2
		pane=New VPane(2048,2048,Color.Black)
		ink=New Color
	End
	
	Method test()
		Local v0:=New Vec2f(100,100)
		Local v1:=New Vec2f(100,300)
		Local v2:=New Vec2f(300,300)
		Local v3:=New Vec2f(300,100)
		pane.canvas.Color=Color.White
		pane.FatCurve(v0,v1,v2,v3)
	End
		
	Method OnRender( display:Canvas ) Override	
		App.RequestRender()				
		pane.Draw(display,zoom)		
		framecount+=1				
		ink.r=(framecount&255)/255.0
		ink.g=(framecount&1023)/1023.0
		ink.b=(framecount&511)/511.0
		pane.canvas.Color=ink
	End

	Method OnKeyEvent( event:KeyEvent ) Override	
		Select event.Type
		Case EventType.KeyDown
			Select event.Key
			Case Key.Space
				pane.Clear(ink )
			Case Key.Escape
				instance.Terminate()
			Case Key.F1
				Fullscreen = Not Fullscreen
			End
		End
		
	End
	
	Field linetool:Bool=False
	Field history:=New Vec2f[4]
							
	Method OnMouseEvent(event:MouseEvent ) Override

		Local x:Int=event.Location.X * zoom
		Local y:Int=event.Location.Y * zoom
		Local b:Int=event.Button

		Local w:Int=event.Wheel.Y
		
		Select event.Type
		
		Case EventType.MouseWheel
			zoom-=w/8.0
			If zoom<1.0/8 zoom=1.0/8
				
		Case EventType.MouseDown
			pane.EndSegment()
			
		Case EventType.MouseMove
			history[0]=history[1]
			history[1]=history[2]
			history[2]=history[3]
			history[3]=New Vec2f(x,y)
		End
		
If linetool
		If drawcount	
			pane.FatLine(mousex,mousey,x,y)		
		Endif
Else
		If drawcount>2 And Not b
'			pane.FatCurve(mx[0],my[0],mx[1],my[1],mx[2],my[2],mx[3],my[3])				
			pane.FatCurve(history[0],history[1],history[2],history[3])				
		Endif
Endif
		mousex=x
		mousey=y
		drawcount+=1
	End	
End

Global title:String="VPaint 0.1"	

Function Main()
	Print title
	instance = New AppInstance	
	New VPaint(title)
	App.Run()	
End

