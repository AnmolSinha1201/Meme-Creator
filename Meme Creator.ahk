#NoEnv
#Include, gdip.ahk

pToken := Gdip_Startup()
InitFile := "init.ini"

SplashTextOn , 200, 50, Loading, Loading..`nPlease wait..
gui, font, s10, Trebuchet MS
Gui, Add, Edit, w200 section gSearch vSearchText hwndhSearch
Gui, Add, ListBox, w200 h370 vTemplateList gTemplateList
Gui, Add, Tab, ys +Theme h400 w550, Meme Creator|Settings

Gui, Tab, 1
Gui, Add, Picture, w500 h290 +0xE hwndhPic
Gui, Add, Text, section +BackgroundTrans, Top Text ::
Gui, Add, Text, +BackgroundTrans, Bottom Text ::
Gui, Add, Edit, w400 ys vTopText gWriteText Disabled
Gui, Add, Edit, w400 vBottomText gWriteText Disabled
Gui, Add, Text, xm section, Save as ::
Gui, Add, Edit, ys w465 vLocation
Gui, Add, Button, ys w100 h30 gBrowse, Browse
Gui, Add, Button, ys w100 h30 gSave vSave Disabled, Save



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
Gui, Add, Checkbox, vBackdropInFinal gSettings, Include backdrops in final image
Gui, Add, Checkbox, vBackdropInCaption gSettings, Include backdrops in caption
Gui, Add, Checkbox, yp+70 vAutoSizeCaption gSettings, Auto size caption


Gui, Add, Text, section +BackgroundTrans, Top caption ::
Gui, Add, Edit, ys w115 vTopTextSize
Gui, Add, Text, ys +BackgroundTrans, Bottom Caption ::
Gui, Add, Edit, ys w115 vBottomTextSize
Gui, Add, Text, section xs +BackgroundTrans yp+35, Save format ::
Gui, Add, DropDownList, ys w355 vSaveFormat, jpg|gif|png

Gui, Add, Button, xm+210 ym+405 w120 h30 section gSaveSettings, Save
Gui, Add, Button, w120 h30 ys gRestoreSettings, Restore Default



Gui, Add, StatusBar
Gui, Show



;####################################################
SetEditCueBanner(hSearch, "Search Template")
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
SplashTextOff
return

Browse:
FileSelectFile, OutVar, S
if(OutVar && !ErrorLevel)
{
	SplitPath, OutVar,,, OutExt
	GuiControl,, Location, % OutVar ((OutExt)?"":"." SaveFormat)
}
return

Save:
Gui, Submit, Nohide
IfExist, % Location
{
	MsgBox, 36, File already exists, File already exists. Do you want to continue?
	IfMsgBox, No
		return
}
if(!Gdip_SaveBitmapToFile(pBitmap, Location, 100))
	SetStatusBar("R", "Image saved")
return

Settings:
Gui, Submit, Nohide
if(BackdropInCaption)
	GuiControl,, BackdropInFinal, 1
BackdropInFinal := 1
IF(BackdropInFinal)
	GuiControl,, ViewBackdrop, 1

GuiControl, Disable%AutoSizeCaption%, TopTextSize
GuiControl, Disable%AutoSizeCaption%, BottomTextSize
return


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
IniWrite(TopTextSize, InitFile, "General", "TopTextSize")
IniWrite(BottomTextSize, InitFile, "General", "BottomTextSize")
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

if(!TopTextSize := IniRead(InitFile, "General", "TopTextSize"))
	TopTextSize := IniWrite(24, InitFile, "General", "TopTextSize")


if(!BottomTextSize := IniRead(InitFile, "General", "BottomTextSize"))
	BottomTextSize := IniWrite(24, InitFile, "General", "BottomTextSize")

if(!SaveFormat := IniRead(InitFile, "General", "SaveFormat"))
	SaveFormat := IniWrite("png", InitFile, "General", "SaveFormat")

if(AutoSizeCaption)
{
	GuiControl, Disable, TopTextSize
	GuiControl, Disable, BottomTextSize
}
if(BackdropInCaption)
	BackdropInFinal := IniWrite(1, InitFile, "General", "BackdropInFinal")
if(BackdropInFinal)
	ViewBackdrop := IniWrite(1, InitFile, "General", "ViewBackdrop")

GuiControl,, ViewBackdrop, % ViewBackdrop
GuiControl,, BorderAroundText, % BorderAroundText
GuiControl,, BackdropInFinal, % BackdropInFinal
GuiControl,, BackdropInCaption, % BackdropInCaption
GuiControl,, BackdropColor, % BackdropColor
GuiControl,, TextColor, % TextColor
GuiControl,, AutoSizeCaption, % AutoSizeCaption
GuiControl,, TopTextSize, % TopTextSize
GuiControl,, BottomTextSize, % BottomTextSize
GuiControl, ChooseString, SaveFormat, % SaveFormat`
return

WriteText:
Gui, Submit, Nohide
if(TopText = "" && BottomText = "")
{
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap_BG)
	SetImage(hPic, hBitmap)
	DeleteObject(hBitmap)
	return
}

Gdip_DisposeImage(pBitmap)
pBitmap := Gdip_CreateBitmapFromFile("res/" CurrentImage)
iWidth := Gdip_GetImageWidth(pBitmap)
iHeight := Gdip_GetImageHeight(pBitmap)
if(BackdropInCaption)
{
	Ratio := 500/290
	
	if(iWidth/iHeight > Ratio)
		nWidth := iWidth, nHeight := iWidth/Ratio
	else
		nHeight := iHeight, nWidth := iHeight*Ratio
	
	pBitmap := CreateCentralFrame(pBitmap, nWidth, nHeight, ViewBackdrop?BackdropColor:0)
}
else
	nWidth := iWidth, nHeight := iHeight

G := Gdip_GraphicsFromImage(pBitmap)
InitialMultiplier := 1/6
Partition := 0.405
if(TextColor > 0xFFFFFFFF || TextColor < 0)
{
	SetStatusBar("E", "Illegal text color")
	return
}
if(TopText)
{
	if(AutoSizeCaption)
	{
		ThisMultiplier := !ThisMultiplier ?InitialMultiplier : ThisMultiplier
	
		CreateRectF(RC, 0, 0, nWidth, nHeight)
		hFamily := Gdip_FontFamilyCreate("Arial")
		hFont := Gdip_FontCreate(hFamily, nHeight*ThisMultiplier, 1)
		hFormat := Gdip_StringFormatCreate(0x4000)
		Measure := Gdip_MeasureString(G, TopText, hFont, hFormat, RC)
		if(StrSplit(Measure, "|")[4] > nHeight*Partition)
			ThisMultiplier/=2
		
		Gdip_DeleteStringFormat(hFormat)   
		Gdip_DeleteFont(hFont)
		Gdip_DeleteFontFamily(hFamily)
		
		hFont := Gdip_FontCreate(hFamily, nHeight*ThisMultiplier*2, 1)
		hFormat := Gdip_StringFormatCreate(0x4000)
		Measure := Gdip_MeasureString(G, TopText, hFont, hFormat, RC)
		if(StrSplit(Measure, "|")[4] < nHeight*Partition)
			ThisMultiplier*=2
		
		Gdip_DeleteStringFormat(hFormat)   
		Gdip_DeleteFont(hFont)
		Gdip_DeleteFontFamily(hFamily)
		
		
	}
	
	
	
	Path := Gdip_CreatePath()
	FontFamily := Gdip_FontFamilyCreate("Arial")

	hFormat := Gdip_StringFormatCreate(0x4000) ;StringFormatFlagsNoClip
	Gdip_SetStringFormatAlign(hFormat, 1) ; Center = 1
	Gdip_SetTextRenderingHint(G, 4) ; AntiAlias = 4
	
	Style := 1 ; FontStyleBold
	Size := Round((AutoSizeCaption)?(nHeight*ThisMultiplier):TopTextSize)
	CreateRectF(RectF, 0, 0, nWidth, nHeight)
	DllCall("Gdiplus\GdipAddPathString", "Ptr", Path, "WStr", TopText, "Int", -1, "Ptr", FontFamily
                                             , "Int", Style, "Float", Size, "Ptr", &RectF, "Ptr", hFormat)
	pPen2 := Gdip_CreatePen(0xFF000000, 4)
	DllCall("gdiplus\GdipSetPenLineJoin", "Uint", pPen2, "uInt", 2)
	DllCall("gdiplus\GdipDrawPath", "UInt", G, "UInt", pPen2, "UInt", Path)
	Gdip_TextToGraphics(G, TopText, "x0 y0 Center c" SubStr(TextColor, 3) " Bold s" . Size, "Arial", nWidth, nHeight)
	
	Gdip_DeletePen(pPen2)
	Gdip_DeleteStringFormat(hFormat)
	Gdip_DeleteFontFamily(FontFamily)
	Gdip_DeletePath(Path)
}
if(BottomText)
{
	if(AutoSizeCaption)
	{
		ThisMultiplier2 := !ThisMultiplier2 ?InitialMultiplier : ThisMultiplier2
	
		CreateRectF(RC, 0, 0, nWidth, nHeight)
		hFamily := Gdip_FontFamilyCreate("Arial")
		hFont := Gdip_FontCreate(hFamily, nHeight*ThisMultiplier2, 1)
		hFormat := Gdip_StringFormatCreate(0x4000)
		Measure := Gdip_MeasureString(G, BottomText, hFont, hFormat, RC)
		if(StrSplit(Measure, "|")[4] > nHeight*Partition)
			ThisMultiplier2/=2
		
		Gdip_DeleteStringFormat(hFormat)   
		Gdip_DeleteFont(hFont)
		Gdip_DeleteFontFamily(hFamily)
		
		hFont := Gdip_FontCreate(hFamily, nHeight*ThisMultiplier2*2, 1)
		hFormat := Gdip_StringFormatCreate(0x4000)
		Measure := Gdip_MeasureString(G, BottomText, hFont, hFormat, RC)
		if(StrSplit(Measure, "|")[4] < nHeight*Partition)
			ThisMultiplier2*=2
	
		Gdip_DeleteStringFormat(hFormat)   
		Gdip_DeleteFont(hFont)
		Gdip_DeleteFontFamily(hFamily)
		Gdip_DeletePath(Path)
	}
	
	Path := Gdip_CreatePath()
	FontFamily := Gdip_FontFamilyCreate("Arial")

	hFormat := Gdip_StringFormatCreate(0x4000) ;StringFormatFlagsNoClip
	Gdip_SetStringFormatAlign(hFormat, 1) ; Center = 1
	Gdip_SetTextRenderingHint(G, 4) ; AntiAlias = 4
	
	Style := 1 ; FontStyleBold
	Size := Round((AutoSizeCaption)?(nHeight*ThisMultiplier2):BottomTextSize)
	
	hFont := Gdip_FontCreate(hFamily, Size, 1)
	CreateRectF(RC, 0, 0, nWidth, nHeight)
	ReturnRC := Gdip_MeasureString(G, BottomText, hFont, hFormat, RC)
	StringSplit, ReturnRC, ReturnRC, |
	
	CreateRectF(RectF, 0, (nHeight-ReturnRC4), nWidth, nHeight)
	ToolTip, % DllCall("Gdiplus\GdipAddPathString", "Ptr", Path, "WStr", BottomText, "Int", -1, "Ptr", FontFamily
                                             , "Int", Style, "Float", Size, "Ptr", &RectF, "Ptr", hFormat)
	pPen2 := Gdip_CreatePen(0xFF000000, 4)
	DllCall("gdiplus\GdipSetPenLineJoin", "Uint", pPen2, "uInt", 2)
	DllCall("gdiplus\GdipDrawPath", "UInt", G, "UInt", pPen2, "UInt", Path)
	
	Gdip_TextToGraphics(G, BottomText, "x0 y0 c" SubStr(TextColor, 3) " Center Bold bottom s" . Size, "Arial", nWidth, nHeight)
	
	Gdip_DeletePen(pPen2)
	Gdip_DeleteFont(hFont)
	Gdip_DeleteStringFormat(hFormat)
	Gdip_DeleteFontFamily(FontFamily)
}

hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap2 := CreateCentralFrame(Rescale(pBitmap, 500, 290, 0), 500, 290, ViewBackdrop?BackdropColor:0))
SetImage(hPic, hBitmap)
Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap2), DeleteObject(hBitmap)
return

TemplateList:
Gui, Submit, Nohide
if(!TemplateList)
	return
Gdip_DisposeImage(pBitmap_BG)
Loop, Parse, MasterList, |
{
	SplitPath, A_LoopField,,,, FileName
	if(FileName = TemplateList)
	{
		currentImage := A_LoopField
		pBitmap_BG := CreateCentralFrame(Rescale(Gdip_CreateBitmapFromFile("res/" A_LoopField), 500, 290), 500, 290, ViewBackdrop?BackdropColor:0)
		hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap_BG)
		SetImage(hPic, hBitmap)
		DeleteObject(hBitmap)
		break
	}
}
GuiControl, Enable, TopText
GuiControl, Enable, BottomText
GuiControl, Enable, Save
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

GuiClose:
Gdip_ShutDown(pToken)
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

SetEditCueBanner(hWnd, Cue) 
{
   Static EM_SETCUEBANNER := (0x1500 + 1)
   Return DllCall("User32.dll\SendMessageW", "Ptr", hWnd, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}