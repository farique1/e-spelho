#include <GDIPlus.au3>
#Include <Color.au3>
#include <File.au3>

Global $iTolerance = 30, $sDrive, $sDir, $sFileName, $sExtension

;~ _InvertFile("News\QRCodes\link"&"1"&".bmp","inv-")

Func _InvertFile($sBMP_Path,$prefix)

	_PathSplit ($sBMP_Path, $sDrive, $sDir, $sFileName, $sExtension)

	; Load original image
	_GDIPlus_Startup()
	$hImage = _GDIPlus_ImageLoadFromFile($sBMP_Path)
	If @error Then
		_GDIPlus_Shutdown()
		Exit
	EndIf

	Global $GuiSizeX = _GDIPlus_ImageGetWidth($hImage)
	Global $GuiSizeY = _GDIPlus_ImageGetHeight($hImage)

	; Display original image
	$hBitmap_GUI = GUICreate("Original Bitmap", $GuiSizeX, $GuiSizeY, 100, 100)

	; Create Double Buffer, so the doesn't need to be repainted on PAINT-Event
	$hGraphicGUI = _GDIPlus_GraphicsCreateFromHWND($hBitmap_GUI)
	$hBMPBuff = _GDIPlus_BitmapCreateFromGraphics($GuiSizeX, $GuiSizeY, $hGraphicGUI)
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($hBMPBuff)

	_GDIPlus_GraphicsDrawImageRect($hGraphic, $hImage, 0, 0, $GuiSizeX, $GuiSizeY)
	; Invert the image
	Local $hBitmap = Image_Invert($hBMPBuff, 0, 0, $GuiSizeX, $GuiSizeY)
	If _GDIPlus_ImageSaveToFile($hBitmap, $sDir&$prefix&$sFileName&$sExtension) =  False Then MsgBox(16 , "Error", "Inverted image not created")

	GUIDelete ($hBitmap_GUI)

	_GDIPlus_ImageDispose ($hImage)
	_WinAPI_DeleteObject($hBMPBuff)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_GraphicsDispose($hGraphicGUI)
	_GDIPlus_Shutdown()
EndFunc

Func Image_Invert($hImage2, $iStartPosX = 0, $iStartPosY = 0, $GuiSizeX = Default, $GuiSizeY = Default)
    Local $hBitmap1, $Reslt, $width, $height, $stride, $format, $Scan0, $v_Buffer, $v_Value, $iIW, $iIH
    $iIW = _GDIPlus_ImageGetWidth($hImage2)
    $iIH = _GDIPlus_ImageGetHeight($hImage2)
    If $GuiSizeX = Default Or $GuiSizeX > $iIW - $iStartPosX Then $GuiSizeX = $iIW - $iStartPosX
    If $GuiSizeY = Default Or $GuiSizeY > $iIH - $iStartPosY Then $GuiSizeY = $iIH - $iStartPosY
    $hBitmap1 = _GDIPlus_BitmapCloneArea($hImage2, $iStartPosX, $iStartPosY, $GuiSizeX, $GuiSizeY, $GDIP_PXF32ARGB)
    $Reslt = _GDIPlus_BitmapLockBits($hBitmap1, 0, 0, $GuiSizeX, $GuiSizeY, BitOR($GDIP_ILMREAD, $GDIP_ILMWRITE), $GDIP_PXF32ARGB)
   ;Get the returned values of _GDIPlus_BitmapLockBits ()
    $width = DllStructGetData($Reslt, "width")
    $height = DllStructGetData($Reslt, "height")
    $stride = DllStructGetData($Reslt, "stride")
    $format = DllStructGetData($Reslt, "format")
    $Scan0 = DllStructGetData($Reslt, "Scan0")
    For $i = 0 To $GuiSizeX - 1
        For $j = 0 To $GuiSizeY - 1
            $v_Buffer = DllStructCreate("dword", $Scan0 + ($j * $stride) + ($i * 4))
        ; Get colour value of pixel
            $v_Value = DllStructGetData($v_Buffer, 1)
        ; Invert
            If (Abs(_ColorGetBlue ($v_Value) - 0x80) <= $iTolerance And _ ; Blue
                Abs(_ColorGetGreen($v_Value) - 0x80) <= $iTolerance And _ ; Green
                Abs(_ColorGetRed  ($v_Value) - 0x80) <= $iTolerance) Then ; Red
                DllStructSetData($v_Buffer, 1, BitAND((0x7F7F7F + $v_Value) , 0xFFFFFF))
            Else
                DllStructSetData($v_Buffer, 1, BitXOR($v_Value ,0xFFFFFF))
            EndIf
        Next
    Next
    _GDIPlus_BitmapUnlockBits($hBitmap1, $Reslt)
    Return $hBitmap1
EndFunc  ;==>Image_Invert
