#NoEnv
#Include, gdip.ahk

pToken := Gdip_Startup()
InitFile := "init.ini"

SplashTextOn , 200, 50, Loading, Loading..`nPlease wait..
gui, font, s10, Trebuchet MS
Gui, Add, Edit, w200 section gSearch vSearchText
Gui, Add, ListBox, w200 h370 vTemplateList gTemplateList
Gui, Add, Tab, ys +Theme h400 w550, Meme Creator|Settings

Gui, Tab, 1
Gui, Add, Picture, w500 h290 +0xE hwndhPic, res\Sam Winchester.gif
Gui, Add, Text, section +BackgroundTrans, Top Text ::
Gui, Add, Text, +BackgroundTrans, Bottom Text ::
Gui, Add, Edit, w400 ys vTopText gTopText
Gui, Add, Edit, w400
Gui, Add, Text, xm section, Save as ::
Gui, Add, Edit, ys w465
Gui, Add, Button, ys w100 h30, Browse
Gui, Add, Button, ys w100 h30, Save



Gui, Tab, 2
Gui, Add, Text, +BackgroundTrans, :: Settings ::
Gui, Add, Text, h1 w350 +Border
Gui, Add, Text, h1 w200 +Border

Gui, Add, CheckBox, vViewBackdrop, View Backdrop
Gui, Add, Text, +BackgroundTrans section, Backdrop Color ::
Gui, Add, Text, +BackgroundTrans, Text Color ::
Gui, Add, Edit, w350 ys vBackdropColor
Gui, Add, Edit, w350 vTextColor
Gui, Add, Checkbox, xs vBorderAroundText, Border around text
Gui, Add, Checkbox, vBackdropInFinal, Include backdrops in final image
Gui, Add, Checkbox, vBackdropInCaption, Include backdrops in caption
Gui, Add, Checkbox, yp+70 vAutoSizeCaption, Auto size caption


Gui, Add, Text, section +BackgroundTrans, Size ::
Gui, Add, Text, xs +BackgroundTrans yp+35, Save format ::
Gui, Add, Edit, ys w350 vTextSize
Gui, Add, DropDownList, w350 vSaveFormat, jpg|gif|png

Gui, Add, Button, xm+210 ym+405 w120 h30 section gSaveSettings, Save
Gui, Add, Button, w120 h30 ys gRestoreSettings, Restore Default



Gui, Add, StatusBar
Gui, Show
SplashTextOff

;####################################################
SetStatusBar("W", "Scanning")
Loop, res/*.*
{
	if A_LoopFileExt in gif,jpg,jpeg,png
	{
		MasterList := MasterList "|" A_LoopFileName
		List := List "|" SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - StrLen(A_LoopFileExt) - 1)
	}
}
MasterList := Trim(MasterList, "|")
GuiControl,, TemplateList, % Trim(List, "|")

SetStatusBar("W", "Initializing")
gosub, initini

SetStatusBar("R", "Ready")

return


TopText:
Gui, Submit, Nohide
;~ MsgBox, % pBitmap_BG
pPath := Gdip_CreatePath(0)
ToolTip, % GdipAddPathString(path, "asd", StrLen("asd"), "Arial", 0, 48, 1, "asd")
;~ ToolTip, % Gdip_AddString(pPath, "asd","Arial", "Center r4 c00000000")
return

GdipAddPathString(path, string, length, FontFamily, style, emSize, layoutRect, GpStringFormat) ;using path, string, FontFamily only for now
{	
	pFontFamily := Gdip_FontFamilyCreate(FontFamily)
	
	CreateRectF(ByRef RectF, 0, 0, 100, 100)
	hFormat := Gdip_StringFormatCreate(0x4000)
	return, DllCall("gdiplus\GdipAddPathString", "UInt", Path,  "UInt", &String, "Int", -1, "Uint",pFontFamily, "Int", 0, "Float", 12,"UInt", &RectF, "UInt", hFormat)
	;~ return, DllCall("gdiplus\GdipAddPathString", A_PtrSize ? "UPtr" : "UInt", Path, "uptr", &string, "int", -1, A_PtrSize ? "UPtr" : "UInt", pFontFamily, "int", 0, "float", 24, A_PtrSize ? "UPtr" : "UInt", &RectF, A_PtrSize ? "UPtr" : "UInt", hFormat)
}

Gdip_AddString(Path, sString,fontName, options,stringFormat=0x4000)
{
   nSize := DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "UInt", &sString, "Int", -1, "UInt", 0, "Int", 0)
   VarSetCapacity(wString, nSize*2)
   DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "UInt", &sString, "Int", -1, "UInt", &wString, "Int", nSize)

	hFamily := Gdip_FontFamilyCreate(fontName)
	RegExMatch(Options, "i)X([\-0-9]+)", xpos)
	RegExMatch(Options, "i)Y([\-0-9]+)", ypos)
	RegExMatch(Options, "i)W([0-9]+)", Width)
	RegExMatch(Options, "i)H([0-9]+)", Height)
	RegExMatch(Options, "i)R([0-9])", Rendering)	
		
	Style := 0, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
	Loop, Parse, Styles, |
	{
		If RegExMatch(Options, "i)\b" A_loopField)
		Style |= (A_LoopField != "StrikeOut") ? (A_Index-1) : 8
	}
	RegExMatch(Options, "i)S([0-9]+)", fontSize)
	Align := 0, Alignments := "Near|Left|Centre|Center|Far|Right"
	Loop, Parse, Alignments, |
	{
		If RegExMatch(Options, "i)\b" A_loopField)
		Align |= A_Index//2.1      ; 0|0|1|1|2|2
	}
	hFormat := Gdip_StringFormatCreate(stringFormat)
	Gdip_SetStringFormatAlign(hFormat, Align)	
	Gdip_SetTextRenderingHint(pGraphics, Rendering)
	CreateRectF(textbox, xpos1, ypos1, Width1, Height1)	
	iRet := DllCall("gdiplus\GdipAddPathString", "UInt", Path,  "UInt", &wString, "Int", -1, "Uint",hFamily, "Int", Style, "Float", fontSize1,"UInt", &textbox, "UInt", hFormat)
	Gdip_DeleteFontFamily(hFamily)
	Gdip_DeleteStringFormat(hFormat)
	return iRet 			
}

RestoreSettings:
FileDelete, % InitFile
if(ErrorLevel)
{
	SetStatusBar("E", "Error restoring default")
	return
}
gosub, initini
SetStatusBar("R", "Successfully Restored")
return

SaveSettings:
Gui, Submit, Nohide
if(BackdropColor > 0xFFFFFFFF || BackdropColor < 0)
{
	SetStatusBar("E", "Illegal backdrop color")
	return
}	
if(TextColor > 0xFFFFFFFF || TextColor < 0)
{
	SetStatusBar("E", "Illegal text color")
	return
}	
IniWrite(ViewBackdrop, InitFile, "General", "ViewBackdrop")
IniWrite(BorderAroundText, InitFile, "General", "BorderAroundText")
IniWrite(BackdropInFinal, InitFile, "General", "BackdropInFinal")
IniWrite(BackdropInCaption, InitFile, "General", "BackdropInCaption")
IniWrite(BackdropColor, InitFile, "General", "BackdropColor")
IniWrite(TextColor, InitFile, "General", "TextColor")
IniWrite(AutoSizeCaption, InitFile, "General", "AutoSizeCaption")
IniWrite(TextSize, InitFile, "General", "TextSize")
IniWrite(SaveFormat, InitFile, "General", "SaveFormat")

SetStatusBar("R", "Successfully Saved")
return

initini:
if(!ViewBackdrop := IniRead(InitFile, "General", "ViewBackdrop"))
	ViewBackdrop := IniWrite(1, InitFile, "General", "ViewBackdrop")

if(!BorderAroundText := IniRead(InitFile, "General", "BorderAroundText"))
	BorderAroundText := IniWrite(1, InitFile, "General", "BorderAroundText")

if(!BackdropInFinal := IniRead(InitFile, "General", "BackdropInFinal"))
	BackdropInFinal := IniWrite(0, InitFile, "General", "BackdropInFinal")

if(!BackdropInCaption := IniRead(InitFile, "General", "BackdropInCaption"))
	BackdropInCaption := IniWrite(0, InitFile, "General", "BackdropInCaption")

if(!BackdropColor := IniRead(InitFile, "General", "BackdropColor"))
	BackdropColor := IniWrite(0xFF000000, InitFile, "General", "BackdropColor")

if(!TextColor := IniRead(InitFile, "General", "TextColor"))
	TextColor := IniWrite(0xFFFFFFFF, InitFile, "General", "TextColor")

if(!AutoSizeCaption := IniRead(InitFile, "General", "AutoSizeCaption"))
	AutoSizeCaption := IniWrite(1, InitFile, "General", "AutoSizeCaption")

if(!TextSize := IniRead(InitFile, "General", "TextSize"))
	TextSize := IniWrite(24, InitFile, "General", "TextSize")

if(!SaveFormat := IniRead(InitFile, "General", "SaveFormat"))
	SaveFormat := IniWrite("png", InitFile, "General", "SaveFormat")

if(AutoSizeCaption)
	GuiControl, Disable, TextSize
if(BackdropInCaption)
	BackdropInFinal := IniWrite(1, InitFile, "General", "BackdropInFinal")

GuiControl,, ViewBackdrop, % ViewBackdrop
GuiControl,, BorderAroundText, % BorderAroundText
GuiControl,, BackdropInFinal, % BackdropInFinal
GuiControl,, BackdropInCaption, % BackdropInCaption
GuiControl,, BackdropColor, % BackdropColor
GuiControl,, TextColor, % TextColor
GuiControl,, AutoSizeCaption, % AutoSizeCaption
GuiControl,, TextSize, % TextSize
GuiControl, ChooseString, SaveFormat, % SaveFormat`
return

TemplateList:
Gui, Submit, Nohide
Gdip_DisposeImage(pBitmap_BG)
Loop, Parse, MasterList, |
{
	SplitPath, A_LoopField,,,, FileName
	if(FileName = TemplateList)
	{
		pBitmap_BG := CreateCentralFrame(Rescale(Gdip_CreateBitmapFromFile("res/" A_LoopField), 500, 290), 500, 290)
		hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap_BG)
		SetImage(hPic, hBitmap)
		DeleteObject(hBitmap)
		break
	}
}
return

Search:
Gui, Submit, Nohide
List := ""
Loop, Parse, MasterList, |
{
	SplitPath, A_LoopField,,,, FileName
	if(InStr(FileName, SearchText))
		List := List "|" FileName
}
GuiControl,, TemplateList, % "|" Trim(List, "|")
return

esc::
Gdip_ShutDown(pToken)
GuiClose:
ExitApp


SetStatusBar(State = "W", Line = "") ; W (working)/R (ready)/E (error)
{
	W := 250, R := 302, E := 132
	SB_SetIcon("Shell32.dll", %State%)
	SB_SetText(Line)
}

Rescale(ByRef pBitmapO, width, height, dispose=1)
{
	oWidth := Gdip_GetImageWidth(pBitmapO)
	oHeight := Gdip_GetImageHeight(pBitmapO)
	
	rWidth := width/oWidth
	rHeight := height/oHeight
	
	ratio := (rWidth < rHeight)? rWidth : rHeight
	nWidth := oWidth*ratio
	nHeight := oHeight*ratio
	
	pBitmap := Gdip_CreateBitmap(nWidth, nHeight)
	G := Gdip_GraphicsFromImage(pBitmap)
	Gdip_DrawImage(G, pBitmapO, 0, 0, nWidth, nHeight)
	Gdip_DeleteGraphics(G)
	if(Dispose)
		Gdip_DisposeImage(pBitmapO)
	
	return, pBitmap
}

CreateCentralFrame(ByRef pBitmapO, Width, Height, Color=0xFF000000, Dispose=1)
{
	iWidth := Gdip_GetImageWidth(pBitmapO)
	iHeight := Gdip_GetImageHeight(pBitmapO)
	
	y := (Height-iHeight)/2
	y := (y>0)?y:0
	x := (Width-iWidth)/2
	x := (x>0)?x:0
	
	nWidth := (Width>iWidth)?Width:iWidth
	nHeight := (Height>iHeight)?Height:iHeight
	
	pBitmap := Gdip_CreateBitmap(nWidth, nHeight)
	G := Gdip_GraphicsFromImage(pBitmap)
	pBrush := Gdip_BrushCreateSolid(Color)
	Gdip_FillRectangle(G, pBrush, 0, 0, nWidth, nHeight)
	Gdip_DeleteBrush(pBrush)
	Gdip_DrawImage(G, pBitmapO, x, y, iWidth, iHeight)
	
	Gdip_DeleteGraphics(G)
	if(Dispose)
		Gdip_DisposeImage(pBitmapO)
	
	return, pBitmap
}

IniRead(FileName, Section, Key)
{
	IniRead, Dummy, % FileName, % Section, % Key, % A_Space
	return, Dummy
}

IniWrite(Value, FileName, Section, Key)
{
	IniWrite, % Value, % FileName, % Section, % Key
	return, Value
}