#NoEnv
#Include GDIP.ahk
Token := Gdip_StartUp()
Path := Gdip_CreatePath()
MsgBox, 0, Path, %Path%
FontFamily := Gdip_FontFamilyCreate("Times New Roman")
MsgBox, 0, FontFamily, %FontFamily%
String := "Hello World"
Style := 0 ; FontStyleRegular
Size := 48
CreateRectF(RectF, 50, 50, 150, 100)
Result := DllCall("Gdiplus\GdipAddPathString", "Ptr", Path, "WStr", String, "Int", -1, "Ptr", FontFamily
                                             , "Int", Style, "Float", 48, "Ptr", &RectF, "Ptr", 0)
MsgBox, 0, Result, %Result%
Gdip_DeleteFontFamily(FontFamily)
Gdip_DeletePath(Path)
Gdip_ShutDown(Token)
ExitApp