
Namespace ted2

Using std.chartype

Const COLOR_NONE:=0
Const COLOR_IDENT:=1
Const COLOR_KEYWORD:=2
Const COLOR_STRING:=3
Const COLOR_NUMBER:=4
Const COLOR_COMMENT:=5
Const COLOR_PREPROC:=6
Const COLOR_OTHER:=7

Function Mx2TextHighlighter:Int( text:String,colors:Byte[],tags:String[],sol:Int,eol:Int,state:Int )

	Local i0:=sol
	
	Local icolor:=0
	Local itag:=""
	Local istart:=sol
	Local preproc:=False
	
	If state>-1 icolor=COLOR_COMMENT
	
	While i0<eol
	
		Local start:=i0
		Local chr:=text[i0]
		i0+=1
		If IsSpace( chr ) Continue
		
		If chr=35 And istart=sol
			preproc=True
			If state=-1 icolor=COLOR_PREPROC
			Continue
		Endif
		
		If preproc And (IsAlpha( chr ) Or chr=95)

			While i0<eol And (IsAlpha( text[i0] ) Or IsDigit( text[i0] )  Or text[i0]=95)
				i0+=1
			Wend
			
			Local id:=text.Slice( start,i0 )
			
			Select id.ToLower()
			Case "rem"
				state+=1
				icolor=COLOR_COMMENT
				itag=""
			Case "end"
				If state>-1 
					state-=1
					icolor=COLOR_COMMENT
					itag=""
				Endif
			End
			
			Exit
		
		Endif
		
		If state>-1 Or preproc Exit
		
		Local color:=icolor
		Local tag:=itag
		
		If chr=39
		
			i0=eol
			color=COLOR_COMMENT
			tag=""
			
		Else If chr=34
		
			While i0<eol And text[i0]<>34
				i0+=1
			Wend
			If i0<eol i0+=1
			
			color=COLOR_STRING
			tag=""
			
		Else If IsAlpha( chr ) Or chr=95

			While i0<eol And (IsAlpha( text[i0] ) Or IsDigit( text[i0] )  Or text[i0]=95)
				i0+=1
			Wend
			
			Local id:=text.Slice( start,i0 )
			
			If preproc And istart=sol
			
				Select id.ToLower()
				Case "rem"				
					state+=1
				Case "end"
					state=Max( state-1,-1 )
				End
				
				icolor=COLOR_COMMENT
				itag=""
				
				Exit
			Else
			
				color=COLOR_IDENT
				tag=id
				
				If Mx2Keywords.Contains( id.ToLower() ) 
					color=COLOR_KEYWORD
					tag=id.ToLower()
				endif
			
			Endif
			
		Else If IsDigit( chr )
		
			While i0<eol And IsDigit( text[i0] )
				i0+=1
			Wend
			
			color=COLOR_NUMBER
			tag=""
			
		Else If chr=36 And i0<eol And IsHexDigit( text[i0] )
		
			i0+=1
			While i0<eol And IsHexDigit( text[i0] )
				i0+=1
			Wend
			
			color=COLOR_NUMBER
			tag=""
			
		Else
			
			color=COLOR_NONE
			tag=""
			
		Endif
		
		If color=icolor Continue
		
		For Local i:=istart Until start
			colors[i]=icolor
			tags[i]=itag
		Next
		
		icolor=color
		itag=tag
		istart=start
	
	Wend
	
	For Local i:=istart Until eol
		colors[i]=icolor
		tags[i]=itag
	Next
	
	Return state

End
