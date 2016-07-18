
Namespace myapp

#Import "<std>"
#Import "<mojo>"

Using std..
Using mojo..

Class MyWindow Extends Window

	Field framecount:=0

	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
	
		Local statusText:="status: framecount="+framecount+" fps="+App.FPS+" ms="+App.Millisecs
	
		canvas.DrawText( statusText, 0, Height, 0, 1 )
		
		framecount+=1
	
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
