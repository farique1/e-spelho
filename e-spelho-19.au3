#include <Array.au3>
#include <Color.au3>
#include <Date.au3>
#include <File.au3>
#include <FTPEx.au3>
#include <GDIPlus.au3>
#include <GuiConstants.au3>
#include <IE.au3>
#include <Misc.au3>
#include <String.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include "ArrayElementsMode.au3"
#include "DTC.au3"
#include "EpochDecrypt.au3"
#include "InvertFile.au3"
#include "ISOWeekNumber.au3"
#include "StringSize.au3"

; Missing
;	Test if there are less than 5 news
;
; Populate / Refresh times
	;~ 	Traffic + Stats
	;~ 		repopulate 7:00 > 11:30 + 30min
	;~		traffic 7:00 > 12:00 mon > fri
	;~ 		events 12:00 > 7:00 sat sun
	;~ 		refresh + 1min
	;~ 	Cleaning Lady
	;~ 		repopulate 00:00 + 24h
	;~ 	News
	;~ 		repopulate 00:00 + 24h
	;~ 		refresh + 25s
	;~ 	Weather
	;~ 		repopulate 1h5m
	;~ 	Calendar
	;~ 		repopulate 00:00 + 24h
	;~ 		refresh + 5s
	;~ 	Menssagens
	;~ 		repopulate 00:00 + 24h
	;~ 		refresh + 5s
	;~ 	Lend
	;~ 		repopulate 00:00 + 24h
	;~ 		refresh + 5s

; Initialize
#Region Inicializa
Global $showGui = 1
Global $aColor [3] = [255,255,255]
Global $debug[] = [ 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1 ]; 0 Traf, 1 News, 2 Weath, 3 WeathF, 4 Cal, 5 Mes, 6 Emp, 7 Evt, 8 Cart, 9 Maps, 10 Comm
                  ; Tr Nw We Fo Ca Ms Em Ev Ct Ma Cm
Global $debug[] = [0,0,0,0,0,0,0,0,0,0,0]; Liga tudo
Global $sizeX = 1024, $sizeY = 1280, $offset = 0, $margin = 0
Global $cor1 = 0xFFFFFF, $cor2 = 0x909090, $cor3 = 0x707070
Global $FTPisGo = False, $hOpen, $hConn
Global $transComMostra = False
Global $tApTimerDelay = 15000
Global Const $lciWM_SYSCommand = 274
Global Const $lciSC_MonitorPower = 61808
Global Const $lciPower_Off = 2
Global Const $lciPower_On = -1
Global $acende = True
Global $posXdef = @DesktopWidth/2-($sizeX/2)+$offset, $posYalta = @DesktopHeight-$sizeY-$margin

$Gui = GUICreate("e-spelho", $sizeX, $sizeY, $posXdef, $margin, $WS_POPUP)
GUISetBkColor(0x000000)
GUISetFont(24,300,0,"Segoe UI light",$Gui,5)
GUICtrlSetDefColor($cor1)
GUICtrlSetDefBkColor($GUI_BKCOLOR_TRANSPARENT)
$esc = GUICtrlCreateDummy()
$move = GUICtrlCreateDummy()
$hide = GUICtrlCreateDummy()
_WinAPI_ShowCursor(False)

Global $logFileName = "logs\"&StringReplace(_NowCalcDate(),"/","_")&"\log-"&StringReplace(StringReplace(StringReplace(_NowCalc(),"/","_"),":","_")," ","-")&".txt"
If DirGetSize("logs\"&StringReplace(_NowCalcDate(),"/","_")) = -1 Then
	DirCreate("logs\"&StringReplace(_NowCalcDate(),"/","_"))
EndIf

If (@HOUR > 6 and @HOUR < 12) and (@WDAY > 1 and @WDAY < 7) Then $transComMostra = True

; Connect to server
if $debug[4] = 0 or $debug[5] = 0 or $debug[6] = 0 or $debug[10] = 0 Then
	Local $sServer = '<Server URL>'
	Local $sUsername = '<User name>'
	Local $sPass = '<Password>'
	$hOpen =_FTP_Open ("e-spelho")
	$hConn = _FTP_Connect($hOpen, $sServer, $sUsername, $sPass,1,21)
	If not @error Then $FTPisGo = True
EndIf
#EndRegion

; Time
#Region Hora
Global $horaX = 10, $horaY = 10
GUISetCoord($horaX,$horaY)
Global $segundoTemp = @SEC, $minutoTemp = @MIN, $horaTemp = @HOUR, $diaTemp = @MDAY
$hHora = _NowTime(4)
_Date_Time_Convert_Set("lmo", "january,february,march,april,may,june,july,august,september,october,november,december")
_Date_Time_Convert_Set("ldo", "sunday,monday,tuesday,wednesday,thursday,friday,saturday")
_Date_Time_Convert_Set("sdo", 3) ; Each short name is first 3 chars of equivalent long name
_Date_Time_Convert_Set("smo", 3)
$dia = GUICtrlCreateLabel("",$horaX,$horaY,550,50)
$hora = GUICtrlCreateLabel($hHora,$horaX-3,$horay+34,280,140)
	GUICtrlSetFont(-1,86.25)
$tTamLBL = _StringSize($hHora,86.25,300,0,"Segoe UI light")
$segundo = GUICtrlCreateLabel(@Sec,$horaX+$tTamLBL[2],$horaY+59,55)
	GUICtrlSetFont(-1,32.25)
	GUICtrlSetColor(-1, $cor2)
PopulateDia()
#EndRegion

; Create GUI
; Traffic-Commute
#Region Transito Events
Global $transX = 10, $transY = 188
GUISetCoord($transX,$transY)
Global $transT
$transito = GUICtrlCreateLabel("",$transX,$transY,550,50)
$transitoComp = GUICtrlCreateLabel("",$transX,$transY+40,550,50)
	GUICtrlSetFont(-1,15.75)
	GUICtrlSetColor(-1,$cor2)
$transitoLast = GUICtrlCreateLabel("",$transX,$transY+65,550,50)
	GUICtrlSetFont(-1,15.75)
	GUICtrlSetColor(-1,$cor2)
$transitoMedia = GUICtrlCreateLabel("",$transX,$transY+90,550,50)
	GUICtrlSetFont(-1,15.75)
	GUICtrlSetColor(-1,$cor2)
If $transComMostra = True Then
	PopulateTransito()
	PopulateTransitoComp()
	PopulateTransStat()
Else
	PopulateEvents()
EndIf
GetCommute()
#EndRegion

; Cleaning Lady
#Region Gil
Global $gilX = 10, $gilY = 336
GUISetCoord($gilX,$gilY)
Global $gilDia[13], $gilMes[13]
$gilMsg = GUICtrlCreateLabel("",$gilX,$gilY,300,30)
	GUICtrlSetFont(-1,13.5)
for $f = 0 to 12
	$gilDia[$f] = GUICtrlCreateLabel("",$gilX+$f*35,$gilY+20,32,30)
		GUICtrlSetFont(-1,15.75)
	$gilMes[$f] = GUICtrlCreateLabel("",$gilX+$f*35,$gilY+40,32,30)
		GUICtrlSetFont(-1,13.5)
		GUICtrlSetColor(-1,$cor3)
Next
GUICtrlSetPos($gilDia[6],$gilX+6*35,$gilY+16)
PopulateGil()
#EndRegion

; News
#Region News
Global $newsX = 10, $newsY = 411
GUISetCoord($newsX,$newsY)
global $news[5], $newsTimer
for $f = 0 to 4
	$news[$f] = GUICtrlCreateLabel("",$newsX,$newsY+($f+1)*34,500,32)
		GUICtrlSetFont(-1,15.75)
		GUICtrlSetColor(-1,$cor2)
Next
GUICtrlSetColor ($news[0],$cor1)
$newsQRC = GUICtrlCreatePic("News\QRCodes\Blank.jpg",$newsX-5,$newsY+5*34+52,98,98)
$newsExp = GUICtrlCreateLabel("",$newsX+95,$newsY+5*34+50,400,100)
	GUICtrlSetFont(-1,13.5)
PopulateNews()
#EndRegion

; Calendar
#Region Calendar
Global $calX = 10, $calY = 786
GUISetCoord($calX,$calY)
global $cal[6][2], $calTimer
$cal[5][1] = GUICtrlCreateLabel("...",$calX,$calY-30,60,32)
	GUICtrlSetFont(-1,15.75)
	GUICtrlSetColor(-1,$cor2)
for $f = 0 to 4
	$cal[$f][0] = GUICtrlCreateLabel("",$calX,$calY+($f*34),60,32)
		GUICtrlSetFont(-1,15.75)
		GUICtrlSetColor(-1,$cor2)
	$cal[$f][1] = GUICtrlCreateLabel("",$calX+65,$calY+($f*34),450,32)
		GUICtrlSetFont(-1,15.75)
Next
$cal[5][0] = GUICtrlCreateLabel("",$calX,$calY+4*34+20,60,32)
	GUICtrlSetFont(-1,15.75)
	GUICtrlSetColor(-1,$cor2)
PopulateCalendar()
#EndRegion

; Weather
#Region Weather
Global $weX = $sizeX-10, $weY = 10
GUISetCoord($weX,$weY)
GUISetFont(15.75,300,0,"Segoe UI light",$Gui,5)
$wLtimeDlyP = GUICtrlCreatePic("WeatherIcons\blank.jpg",$weX-358,$weY+6,35,35)
$wLtimeDlyN = GUICtrlCreateLabel("",$weX-365,$weY+7,50,30,$SS_CENTER)
	GUICtrlSetColor(-1,$cor2)
$wLwindPic = GUICtrlCreatePic("WeatherIcons\wind-30.jpg",$weX-302,$weY,20,20)
$wLwind = GUICtrlCreateLabel("",$weX-315,$weY+18,50,30,$SS_CENTER)
$wLdistPic = GUICtrlCreatePic("WeatherIcons\dist-30.jpg",$weX-260,$weY,20,20)
$wLdist = GUICtrlCreateLabel("9.5",$weX-270,$weY+18,40,30,$SS_CENTER)
$wLhumPic = GUICtrlCreatePic("WeatherIcons\humi-30.jpg",$weX-216,$weY,20,20)
$wLhum = GUICtrlCreateLabel("100",$weX-225,$weY+18,40,30,$SS_CENTER)
$wLcoverPic = GUICtrlCreatePic("WeatherIcons\cover-30.jpg",$weX-170,$weY,20,20)
$wLcover = GUICtrlCreateLabel("100",$weX-180,$weY+18,40,30,$SS_CENTER)
$wLprepPPic = GUICtrlCreatePic("WeatherIcons\prob-30.jpg",$weX-126,$weY,20,20)
$wLprepP = GUICtrlCreateLabel("100",$weX-135,$weY+18,40,30,$SS_CENTER)
$wLprepIPic = GUICtrlCreatePic("WeatherIcons\amount-30.jpg",$weX-80,$weY,20,20)
$wLprepI = GUICtrlCreateLabel("2.2",$weX-90,$weY+18,40,30,$SS_CENTER)
$wLsunsPic = GUICtrlCreatePic("WeatherIcons\sunset-30.jpg",$weX-28,$weY,20,20)
$wLsuns = GUICtrlCreateLabel("",$weX-45,$weY+18,45,30,$SS_RIGHT)
$wLcond = GUICtrlCreatePic("WeatherIcons\blank.jpg",$weX-304,$weY+76,80,80)
$wLtempe = GUICtrlCreateLabel("",$weX-180,$weY+34,180,140,$SS_RIGHT)
	GUICtrlSetFont(-1,86.25)
$wLtAppa = GUICtrlCreatePic("WeatherIcons\blank.jpg",$weX-35,$weY+126,30,30)

$wLnextCond3 = GUICtrlCreatePic("WeatherIcons\Blank.jpg",$weX-220,$weY+178,28,28)
$wLnextTemp3 = GUICtrlCreateLabel("",$weX-185,$weY+176,30,30,$SS_RIGHT)
$wLnextProbPic3 = GUICtrlCreatePic("WeatherIcons\prob-30.jpg",$weX-145,$weY+180,20,20)
$wLnextProb3 = GUICtrlCreateLabel("100%",$weX-120,$weY+176,45,30,$SS_RIGHT)
$wLnextHour3 = GUICtrlCreateLabel("",$weX-70,$weY+176,70,30,$SS_RIGHT)
$wLnextCond6 = GUICtrlCreatePic("WeatherIcons\Blank.jpg",$weX-220,$weY+210,28,28)
$wLnextTemp6 = GUICtrlCreateLabel("25º",$weX-185,$weY+208,30,30,$SS_RIGHT)
$wLnextProbPic6 = GUICtrlCreatePic("WeatherIcons\prob-30.jpg",$weX-145,$weY+212,20,20)
$wLnextProb6 = GUICtrlCreateLabel("100%",$weX-120,$weY+208,45,30,$SS_RIGHT)
$wLnextHour6 = GUICtrlCreateLabel("às 22:00",$weX-70,$weY+210,70,30,$SS_RIGHT)
$wLluaDia = GUICtrlCreatePic("WeatherIcons\lua-60\lua-60_020.jpg",$weX-300,$weY+178,60,60)
GUISetFont(24,300,0,"Segoe UI light",$Gui,5)
#EndRegion

; Weather forecast
#Region Weather Forecast
Global $wLfore[5][5], $wLforeOver[5]
Global $wfX = $sizex-10, $wfY = 270
GUISetCoord($wfX,$wfY)
for $f = 0 to 4
	$wLfore[$f][4] = GUICtrlCreatePic("WeatherIcons\blank.jpg",$wfX-28,$wfY+10+($f*39),28,28)
	$wLfore[$f][3] = GUICtrlCreateLabel("",$wfX-86,$wfY+0+($f*39),40,50,$SS_RIGHT)
	$wLfore[$f][2] = GUICtrlCreateLabel("",$wfX-132,$wfY+0+($f*39),40,50)
	$wLfore[$f][1] = GUICtrlCreatePic("WeatherIcons\blank.jpg",$wfX-193,$wfY+10+($f*39),28,28)
	$wLfore[$f][0] = GUICtrlCreateLabel("",$wfX-296,$wfY+0+($f*39),70,50,$SS_RIGHT)
	$wLforeOver[$f] = GUICtrlCreateLabel("",$wfX-298,$wfY+9+($f*39),312,38)
	GUICtrlSetBkColor(-1,0x000000)
	_GuiCtrlMakeTrans(-1,$f*35+50)
Next
PopulateWeather()
#EndRegion

; Lend
#Region Emprestimos
Global $empL[6][4]
Global $empX = $sizeX-10, $empY = 520
GUISetCoord($empX,$empY)
$empL[5][1] = GUICtrlCreateLabel("",$empX-60,$empY-30,60,32,$SS_RIGHT)
	GUICtrlSetFont(-1,15.75)
	GUICtrlSetColor(-1,$cor2)
for $f = 0 to 4
$empL[$f][0] = GUICtrlCreateLabel("",$empX-300,$empY-2+($f*55),224,30,$SS_RIGHT)
	GUICtrlSetFont(-1,15.75)
$empL[$f][1] = GUICtrlCreateLabel("",$empX-75,$empY+($f*55),75,35,$SS_RIGHT)
	GUICtrlSetFont(-1,15.75)
	GUICtrlSetColor(-1,$cor2)
$empL[$f][2] = GUICtrlCreateLabel("",$empX-300,$empY+25+($f*55),224,35,$SS_RIGHT)
	GUICtrlSetFont(-1,13.5)
	GUICtrlSetColor(-1,$cor2)
$empL[$f][3] = GUICtrlCreateLabel("",$empX-75,$empY+25+($f*55),75,35,$SS_RIGHT)
	GUICtrlSetFont(-1,13.5)
	GUICtrlSetColor(-1,$cor3)
Next
$empL[5][0] = GUICtrlCreateLabel("",$empX-60,$empY-10+($f*55),60,32,$SS_RIGHT)
	GUICtrlSetFont(-1,15.75)
	GUICtrlSetColor(-1,$cor2)
PopulateEmprestimos()
#EndRegion

; Messages
#Region Messages
Global $mesX = 10, $mesY = $sizeY-350
GUISetCoord($mesX,$mesY)
$mesSauL = GUICtrlCreateLabel("",$mesX,$mesY+60,$sizeX-20,90,$SS_CENTER)
	GUICtrlSetFont(-1,45)
$mesEloL = GUICtrlCreateLabel("",$mesX,$mesY+130,$sizeX-20,90,$SS_CENTER)
	GUICtrlSetFont(-1,45)
$mesNumbL = GUICtrlCreateLabel("",$mesX,$mesY+220,$sizeX-20,30,$SS_CENTER)
	GUICtrlSetFont(-1,13.5)
	GUICtrlSetColor(-1,$cor2)
$mesMessL = GUICtrlCreateLabel("",$mesX,$mesY+240,$sizeX-20,90,$SS_CENTER)
	GUICtrlSetFont(-1,40)
	GUICtrlSetBkColor(-1,$GUI_BKCOLOR_TRANSPARENT)
$mesNomeL = GUICtrlCreateLabel("",$mesX,$mesY+320,$sizeX-20,30,$SS_CENTER)
	GUICtrlSetFont(-1,13.5)
	GUICtrlSetColor(-1,$cor2)
	PopulateMessages()
#EndRegion

; Start
#Region Inicia
Local $iFtpc = _FTP_Close($hConn)
Local $iFtpo = _FTP_Close($hOpen)

Dim $Main_AccelTable[3][2] = [["{a}", $move],["{ESC}", $esc],["{s}", $hide]]
GUISetAccelerators($Main_AccelTable)

$GuiMaps = GUICreate("Maps", $sizeX, $sizeY, $posXdef, $margin, $WS_POPUP)
GUISetBkColor(0x000000)
GUISetFont(24,300,0,"Segoe UI light",$GuiMaps,5)
$escM = GUICtrlCreateDummy()
$OBJECT = ObjCreate("Shell.Explorer.2")
$OBJECT_CTRL = GUICtrlCreateObj($OBJECT, 10, 10, $sizeX-20, $sizeY-20)
if $debug[9] = 0 Then
	_IENavigate($object, "https://www.google.com/maps/@<latitude>,<longitude>,16z/data=!5m1!1e1")
EndIf
LogActivities("Accessed map")
GUISetState(@SW_SHOW, $GuiMaps)
_WinAPI_SetWindowPos($GuiMaps,$HWND_BOTTOM,$posXdef,$margin,0,0,BitOR($SWP_NOSIZE,$SWP_NOACTIVATE))
GUISetState(@SW_DISABLE, $GuiMaps)

Global $GuiCart, $xkImage, $smImage, $hGraphic
$GuiCart = GUICreate("Cartoons", $sizeX, $sizeY, $posXdef, $margin, $WS_POPUP)
GUISetBkColor(0x000000)
GUISetFont(24,300,0,"Segoe UI light",$GuiCart,5)
$xkPanel =  GUICtrlCreatePic("",10,10,0,0)
$smPanel =  GUICtrlCreatePic("",10,10,0,0)
GUISetState(@SW_SHOW, $GuiCart)
_GDIPlus_Startup ()
BaixaCartoons()
AplicaImagens()
LogActivities("Downloaded cartoons")
_WinAPI_SetWindowPos($GuiCart,$HWND_BOTTOM,$posXdef,$margin,0,0,BitOR($SWP_NOSIZE,$SWP_NOACTIVATE))
GUISetState(@SW_DISABLE, $GuiCart)

Opt("GUICoordMode", 1)
GUISetState(@SW_SHOW, $Gui)
Global $newsTimer = _Date_Time_GetTickCount()
Global $empTimer = _Date_Time_GetTickCount()
Global $calTimer = _Date_Time_GetTickCount()
Global $mesTimer = _Date_Time_GetTickCount()
Global $tApTimer = _Date_Time_GetTickCount()
Global $evtTimer = _Date_Time_GetTickCount()
Global $acendeCont = _Date_Time_GetTickCount()
Global $newsShuffle = @HOUR

GUISwitch($Gui)
WinActivate($Gui)
#EndRegion

; Main loop
While 1
	$aMsg = GUIGetMsg(1)
    Switch $aMsg[1]
		Case $Gui
			Switch $aMsg[0]
				Case $esc
					_Monitor(1) ;Turn on monitor
					Exit
				Case $move
					Global $win = WinGetPos($Gui)
					if $win[1] >= 0 Then
						WinMove($Gui,"",$win[0],$posYalta)
						WinMove($GuiCart,"",$win[0],$posYalta)
						AplicaImagens()
						WinMove($GuiMaps,"",$win[0],$posYalta)
					EndIf
					if $win[1] < 0 Then
						WinMove($Gui,"",$win[0],$margin)
						WinMove($GuiCart,"",$win[0],$margin)
						AplicaImagens()
						WinMove($GuiMaps,"",$win[0],$margin)
					EndIf
				Case $hide
					if $showGui = 1 Then
						$showGui = 2
						_WinAPI_SetWindowPos($GuiCart,$HWND_TOP,$posXdef,$margin,0,0,BitOR($SWP_NOSIZE,$SWP_NOACTIVATE))
						AplicaImagens()
					ElseIf $showGui = 2 Then
						$showGui = 3
						_WinAPI_SetWindowPos($GuiMaps,$HWND_TOP,$posXdef,$margin,0,0,BitOR($SWP_NOSIZE,$SWP_NOACTIVATE))
						RefreshMap()
					Else
						$showGui = 1
						_WinAPI_SetWindowPos($Gui,$HWND_TOP,$posXdef,$margin,0,0,$SWP_NOSIZE)
					EndIf
				Case $GUI_EVENT_PRIMARYDOWN
					DllCall("user32.dll", "long", "SendMessage", "hwnd", $Gui, "int", $WM_SYSCOMMAND, "int", 0xF009, "int", 0)
			EndSwitch
		Case $GuiMaps
			Switch $aMsg[0]
				Case $escM
;~ 					Exit
			EndSwitch
	EndSwitch
;~ 	ApagaMonitor()
	Timer()
WEnd

; Main function
Func Timer()
    If @SEC <> $segundoTemp Then
        GUICtrlSetData($segundo,@SEC)
        $segundoTemp = @SEC
    EndIf
	if @MIN <> $minutoTemp Then
		$tTamLBL = _StringSize(_NowTime(4),86.25,300,0,"Segoe UI light")
		GUICtrlSetPos($segundo,$tTamLBL[2]+$horaX)
        GUICtrlSetData($hora,_NowTime(4))
		If (@HOUR > 6 and @HOUR < 12) and (@WDAY > 1 and @WDAY < 7) and $transComMostra = false Then
			$transComMostra = True
			LogActivities("Show Traffic Commute")
		EndIf
		If (@HOUR > 11 or @HOUR < 7) or (@WDAY = 1 or @WDAY = 7) and $transComMostra = True Then
			$transComMostra = False
			LogActivities("Show Events")
			PopulateEvents()
		EndIf
		if Mod(@MIN,30) = 0 and (@HOUR >= 7 and @HOUR <= 11) and @MIN <> $minutoTemp Then
			if $transComMostra = True Then
				PopulateTransito()
				PopulateTransStat()
			EndIf
		EndIf
		if $transComMostra = True Then PopulateTransitoComp()
		$minutoTemp = @MIN
	EndIf
	If @HOUR <> $horaTemp and @MIN > 4 Then
		PopulateWeather()
		$horaTemp = @HOUR
	EndIf
	if Mod(@HOUR,4) = 0 and @HOUR <> 0 and $newsShuffle <> @HOUR Then
		ShuffleNews()
		$newsShuffle = @HOUR
	EndIf
	if @MDAY <> $diaTemp Then
		$diaTemp = @MDAY
		if $debug[4] = 0 or $debug[5] = 0 or $debug[6] = 0 Then
			Local $sServer = '<Server URL>'
			Local $sUsername = '<User name>'
			Local $sPass = '<Password>'
			$hOpen =_FTP_Open ("e-spelho")
			$hConn = _FTP_Connect($hOpen, $sServer, $sUsername, $sPass)
			If not @error Then $FTPisGo = True
		EndIf
		PopulateDia()
		PopulateEvents()
		PopulateGil()
		PopulateNews()
		PopulateCalendar()
		PopulateEmprestimos()
		PopulateMessages()
		GetCommute()
		BaixaCartoons()
		AplicaImagens()
		Local $iFtpc = _FTP_Close($hConn)
		Local $iFtpo = _FTP_Close($hOpen)
	EndIf
	if _Date_Time_GetTickCount() > $tApTimer + $tApTimerDelay Then
		RefreshWeather()
		$tApTimer = _Date_Time_GetTickCount()
	EndIf
	if _Date_Time_GetTickCount() > $evtTimer + 5000 Then
		if $transComMostra = false Then RefreshEvents()
		$evtTimer = _Date_Time_GetTickCount()
	EndIf
	if _Date_Time_GetTickCount() > $calTimer + 5000 Then
		RefreshCalendar()
		$calTimer = _Date_Time_GetTickCount()
	EndIf
	if _Date_Time_GetTickCount() > $empTimer + 5000 Then
		RefreshEmprestimos()
		$empTimer = _Date_Time_GetTickCount()
	EndIf
	if _Date_Time_GetTickCount() > $newsTimer + 25000 Then
		RefreshNews()
		$newsTimer = _Date_Time_GetTickCount()
	EndIf
	if _Date_Time_GetTickCount() > $mesTimer + 5000 Then
		RefreshMessages()
		$mesTimer = _Date_Time_GetTickCount()
	EndIf
EndFunc

; Main Functions
Func PopulateDia()
	$sIn_Date = _NowDate()
	$sOut_DateDia = _Date_Time_Convert($sIn_Date, "dd/MM/yyyy", "dddd, d")
	$sOut_DateMes = _Date_Time_Convert($sIn_Date, "dd/MM/yyyy", "MMMM")
	$sOut_DateAno = _Date_Time_Convert($sIn_Date, "dd/MM/yyyy", "yyyy")
	$pPlaindDate  = $sOut_DateDia&" of "&$sOut_DateMes&" of "&$sOut_DateAno
	GUICtrlSetData($dia,$pPlaindDate)
	LogActivities("Populate Day")
EndFunc

; Cleaning Lady
Func PopulateGil()
	$showGilMsg = ""
	$semanaBaseGil = 41
	$dataHojeGil = _NowCalcDate()
;~ 	$dataHojeGil = "2016/11/20"
	_Date_Time_Convert_Set("ldo", "3,2,1,0,6,5,4"); Change the week days names to numbers that added with today equals next wednesday
	$proxQuaGil = _DateAdd("d",_Date_Time_Convert($dataHojeGil, "yyyy/MM/dd", "dddd"),$dataHojeGil); Find out next wednesday
	_Date_Time_Convert_Set("ldo", "sunday,monday,tuesday,wednesday,thursday,friday,saturday")

	$splitProxQuaGil = StringSplit($proxQuaGil,"/",2)
	$ajusteContador = mod(_ISOWeekNumber($splitProxQuaGil[2],$splitProxQuaGil[1],$splitProxQuaGil[0],0),2)
;   $ajusteContador = 0 or 1, prevent the FOR starting to count a week without the cleaning lady 
	for $f = -11-$ajusteContador to 11+$ajusteContador step 2
		$allQuaGil = _DateAdd("d",$f*7,$proxQuaGil) ; Count weeks before and after next wednesday
		$diasQuaGil = _Date_Time_Convert($allQuaGil, "yyyy/MM/dd", "dd") ; Format to show only the day
		GUICtrlSetData($gilDia[$f/2+6],$diasQuaGil)
		GUICtrlSetColor($gilDia[$f/2+6],$cor3)
		$splitDateGil = StringSplit($allQuaGil,"/",2)
		$semanaGil = _ISOWeekNumber($splitDateGil[2],$splitDateGil[1],$splitDateGil[0],0)
		if mod($semanaGil-$semanaBaseGil,4) = 0 Then GUICtrlSetColor($gilDia[$f/2+6],$cor2)
		if mod($semanaGil-$semanaBaseGil,4) = 0 and $f = 0 Then
			GUICtrlSetColor($gilDia[$f/2+6],$cor1)
			if StringRight($dataHojeGil,2) > $diasQuaGil -7 then
				$showGilMsg = "pay day is next wednesday"
				GUICtrlSetColor($gilMsg,$cor3)
			EndIf
			if StringRight($dataHojeGil,2)+1 = $diasQuaGil then
				$showGilMsg = "pay day is tomorrow"
				GUICtrlSetColor($gilMsg,$cor2)
			EndIf
			if StringRight($dataHojeGil,2) = $diasQuaGil then
				$showGilMsg = "pay day is today"
				GUICtrlSetColor($gilMsg,$cor1)
			EndIf
		EndIf
		GUICtrlSetData($gilMsg,$showGilMsg)
	Next
	$tempMesGil = $diasQuaGil
	for $f = -11-$ajusteContador to 11+$ajusteContador step 2
		$allQuaGil = _DateAdd("d",$f*7,$proxQuaGil) ; Count weeks before and after next wednesday
		$diasQuaGil = _Date_Time_Convert($allQuaGil, "yyyy/MM/dd", "MMM") ; Format to show only the month
		$mesMostraGil = ""
		if $tempMesGil <> $diasQuaGil Then
			$mesMostraGil = $diasQuaGil
			$tempMesGil = $diasQuaGil
		Endif
		GUICtrlSetData($gilMes[$f/2+6],$mesMostraGil)
	Next
	LogActivities("Populate Cleaning Lady")
EndFunc

; Traffic
Func PopulateTransito()
	Global $tSavY = @YEAR,  $tSavM = @MON, $tSavD = @MDAY, $tSavH = @HOUR, $tSavMi = @MIN
	Global $tSavDs = _Date_Time_Convert($tSavY&$tSavM&$tSavD,"yyyyMMdd","ddd")
	Global $tSavDsL = _Date_Time_Convert($tSavY&$tSavM&$tSavD,"yyyyMMdd","dddd")
	if $debug[0] = 0 then ; Enable/disable web search
		; Measure two legs to make a middle point on the trip and better represent the actual road taken on the commute 
		$jJsonT1 = BinaryToString(InetRead("https://maps.googleapis.com/maps/api/distancematrix/json?origins=<latitude>,<longitude>&destinations=<latitude>,<longitude>&mode=driving&departure_time=now&language=pt-BR&key=<API Key>"), 4)
		$jJsonT2 = BinaryToString(InetRead("https://maps.googleapis.com/maps/api/distancematrix/json?origins=<latitude>,<longitude>&destinations=<latitude>,<longitude>&mode=driving&departure_time=now&language=pt-BR&key=<API Key>"), 4)
		$mMatrixT1 = StringSplit($jJsonT1,@LF)
		$mMatrixT2 = StringSplit($jJsonT2,@LF)
		$trans1 = StringMid($mMatrixT1[20],StringInStr($mMatrixT1[20],":")+2)
		$trans2 = StringMid($mMatrixT2[20],StringInStr($mMatrixT2[20],":")+2)
		$transT = Round((Int($trans1)+Int($trans2))/60)
		$transSave = $tSavY&"/"&$tSavM&"/"&$tSavD&"-|-"&$tSavDs&"-|-"&$tSavH&":"&$tSavMi&"-|-"&Floor($transT/60)&":"&StringFormat("%02s",Mod($transT,60))&":00"
		$transDataF = FileOpen("Traffic\tra-"&$tSavY&"_"&$tSavM&"_"&$tSavD&"-"&$tSavDs&"-"&$tSavH&"_"&$tSavMi&"-"&Floor($transT/60)&"_"&StringFormat("%02s",Mod($transT,60))&"_00"&".txt",2)
		FileWrite($transDataF,$transSave)
		FileClose($transDataF)
	EndIf
	$newestF = LeMaisRecente("Traffic\","tra-*.txt")
	$transDataF = FileOpen($newestF,0)
	$transData = FileRead($transDataF)
	FileClose($transDataF)
	$tempoBruto = StringMid($transData,28,7)
	$transT = (StringLeft($tempoBruto,1)*60)+(StringMid($tempoBruto,3,2))
	$transitoTxt = $transT&" minutes to the office"
	if $transT = 60 then $transitoTxt = "one hour to the office"
	if $transT > 60 then $transitoTxt = "more than one hour to the office"
	GUICtrlSetData($transito,$transitoTxt)
	LogActivities("Populate Traffic")
EndFunc

; Commute statistics
Func PopulateTransStat()
	$transLastCom = ""
	$transMedT = 0
	$transMedSamples = 0
	$aFile = _FileListToArray("Commute/","com-*"&$tSavDs&"*.txt")
	if not @error Then
		_ArraySort($aFile)
		$diaFileName = StringReplace(StringMid($aFile[1],5,11),"_","/")
		$transPriSem = _DateDiff("w",$diaFileName,_NowCalcDate())
		for $f = 1 to $transPriSem
			$wildcard = StringReplace(_DateAdd("d",-7*$f,_NowCalcDate()),"/","_")
			$transComI = _ArraySearch($aFile,$wildcard,0,0,0,1)
			if $transLastCom = "" and not @error Then
				$transLastCom = $aFile[$transComI]
				$transNumSem = $f
			EndIf
		Next
		for $f = 1 to $aFile[0]
			$transMedData = FileRead("Commute/"&$aFile[$f])
			$tempoMedBruto = StringMid($transMedData,28,7)
			$transMedT += (StringLeft($tempoMedBruto,1)*60)+(StringMid($tempoMedBruto,3,2))
		Next
		$transMedT = $transMedT / ($f-1)
		$transMedSamples = $f-1
	EndIf
	$transMedText = ""; "not enough data for an average"
	$transLastText = "" ;"no data about past "&StringSplit($tSavDsL,"-")[1]
	if $transLastCom <> "" Then
		$transLastData = FileRead("Commute/"&$transLastCom)
		$tempoLastBruto = StringMid($transLastData,28,7)
		$transLastT = (StringLeft($tempoLastBruto,1)*60)+(StringMid($tempoLastBruto,3,2))
		$transLastS = StringMid($transLastData,20,5)
		$transLastText = $transLastT&" minutes past "&StringSplit($tSavDsL,"-")[1]&", at "&$transLastS
		If $transNumSem > 1 then $transLastText = $transLastT&" minutes, "&$transNumSem&" weeks ago at "&$transLastS
	EndIf
	If $transMedSamples > 1 Then
		$transDiaPlural = ""
		if $transMedSamples > 1 Then $transDiaPlural = "s"
		$transMedText = Round($transMedT,0)&" average minutes on "&$transMedSamples&" "&StringSplit($tSavDsL,"-")[1]&$transDiaPlural
	EndIf
	GUICtrlSetData($transitoLast,$transLastText)
	GUICtrlSetData($transitoMedia,$transMedText)
	LogActivities("Populate Commute Statistics")
EndFunc

; Commute
Func PopulateTransitoComp()
	$transitoCompTxt = "arriving around "& _Date_Time_Convert(_DateAdd("n", $transT, _NowCalc()),"yyyy/MM/dd HH:mm:ss","HH:mm")
	GUICtrlSetData($transitoComp,$transitoCompTxt)
EndFunc

Func GetCommute()
	if $debug[10] = 0 Then
		$comLocF = _FileListToArray("Commute/","com-*.txt")
		_FTP_DirSetCurrent ( $hConn, "/<Server FTP>/iSpelho/commute/" )
		$comRemF = _FTP_ListToArray($hConn, 0)
		Local $conDifF = ObjCreate("Scripting.Dictionary")
		For $f In $comRemF
			$conDifF.Item($f)
		Next
		For $f In $comLocF
			If $conDifF.Exists($f) Then $conDifF.Remove($f)
		Next
		Local $conDifFok = $conDifF.Keys()
		$conDifF = 0
		for $f = 1 to UBound($conDifFok)-1
			_FTP_FileGet($hConn,$conDifFok[$f],"Commute/"&$conDifFok[$f])
		Next
	EndIf
EndFunc

; Events
Func PopulateEvents()
	Global $eSavY = @YEAR,  $eSavM = @MON, $eSavD = @MDAY
	Global $eventInfo[0][6]
	Global $eventAtual = 0
	GUICtrlSetData($transito,"")
	GUICtrlSetData($transitoComp,"")
	GUICtrlSetData($transitoLast,"")
	GUICtrlSetData($transitoMedia,"")
	GUICtrlSetData($transitoMedia,"")
	if $debug[7] = 0 Then
		if not FileExists("Events\evt-"&@YEAR&"_"&@MON&"_"&@MDAY&".txt") Then
			Global $eventJson = BinaryToString(InetRead("https://graph.facebook.com/me/events?access_token=<API Token>"), 4)
			$eventJsonF = FileOpen("Events\evt-"&$eSavY&"_"&$eSavM&"_"&$eSavD&".txt",2)
			FileWrite($eventJsonF,$eventJson)
			FileClose($eventJsonF)
		EndIf
		$newest = "Events\evt-"&$eSavY&"_"&$eSavM&"_"&$eSavD&".txt"
	Else
		$newest = LeMaisRecente("Events/","evt-*.txt")
	EndIf
	$eventJsonF = FileOpen($newest,0)
	$eventJson = FileRead($eventJsonF)
	FileClose($eventJsonF)
	$eventJson = StringReplace($eventJson,"""","*")
	$eventJson = StringReplace($eventJson,"'","*")
	$eventJson = StringReplace($eventJson,"\n"," ")
	$eventLimpo = Execute("'" & StringRegExpReplace($eventJson, "(\\u([[:xdigit:]]{4}))", "' & ChrW(0x$2) & '") & "'")
	$eventJson = StringSplit($eventLimpo,"},{",3)
;~ 	_ArrayDisplay($eventJson)
	if UBound($eventJson)-1 > 0 Then
		for $f = 0 to UBound($eventJson)-1
;~ 			ConsoleWrite("- go!"&@CRLF)
			$saida = _StringBetween($eventJson[$f],"start_time*:*","*:*")
			$eventData = _Date_Time_Convert($saida[0],"yyyy-MM-ddTHH:mm:ss","yyyy/MM/dd")
			$eventDia = _Date_Time_Convert($saida[0],"yyyy-MM-ddTHH:mm:ss","dddd")
			$eventHora = _Date_Time_Convert($saida[0],"yyyy-MM-ddTHH:mm:ss","HH:mm")
			$eventLoc = _StringBetween($eventJson[$f],"{*name*:*","*")[0]
			$eventName = _StringBetween($eventJson[$f],"name*:*","*")[0]
			$eventDiasPara = _DateDiff("d",_NowCalcDate(),$eventData)
			if $eventDiasPara < 0 Then ExitLoop
			_ArrayAdd($eventInfo,$eventData&"|"&$eventDia&"|"&$eventHora&"|"&$eventLoc&"|"&$eventName&"|"&$eventDiasPara)
		Next
		GUICtrlSetData($transitoMedia,"")
;~ 		_ArrayDisplay($eventInfo)
	EndIf
	LogActivities("Populate Events")
	RefreshEvents()
EndFunc

Func RefreshEvents()
	if UBound($eventInfo) > 0 Then
		GUICtrlSetData($transito,$eventInfo[$eventAtual][4])
		GUICtrlSetData($transitoComp,$eventInfo[$eventAtual][3])
		$tempDia = _Date_Time_Convert($eventInfo[$eventAtual][0],"yyyy/MM/dd","d")
		$tempMes = _Date_Time_Convert($eventInfo[$eventAtual][0],"yyyy/MM/dd","MMMM")
		$eventQuando = ", in "&$eventInfo[$eventAtual][5]&" days"
		if $eventInfo[$eventAtual][5] < 3 Then $eventQuando = ", after tomorrow"
		if $eventInfo[$eventAtual][5] < 2 Then $eventQuando = ", tomorrow"
		if $eventInfo[$eventAtual][5] < 1 Then $eventQuando = ", TODAY"
		GUICtrlSetData($transitoLast,$tempDia&" of "&$tempMes&" at "&$eventInfo[$eventAtual][2]&", "&$eventInfo[$eventAtual][1]&$eventQuando)
		if  UBound($eventInfo) > 1 Then
			GUICtrlSetData($transitoMedia,($eventAtual+1)&" of "&UBound($eventInfo)&" events")
		Else
			GUICtrlSetData($transitoMedia,"")
		EndIf
		$eventAtual += 1
		if $eventAtual > UBound($eventInfo)-1 Then $eventAtual = 0
	EndIf
EndFunc

; News
Func PopulateNews()
	global $newsClean[0][3], $newsNow = 0
	Global $nSavY = @YEAR,  $nSavM = @MON, $nSavD = @MDAY, $nSavH = @HOUR
	for $f = 0 to 4
		GUICtrlSetData($news[$f],"")
	Next
	GUICtrlSetData($newsExp,"")
	if $debug[1] = 0 then ;Enable/disable web search
		$newsXMLtemp = BinaryToString(InetRead("https://rss.sciencedaily.com/top/science.xml"), 4)
		$newsXMLtempF = FileOpen("News\news-"&$nSavY&"_"&$nSavM&"_"&$nSavD&"-"&$nSavH&".txt",2)
		FileWrite($newsXMLtempF,$newsXMLtemp)
		FileClose($newsXMLtempF)
	EndIf
	$newestF = LeMaisRecente("News/","news-*.txt")
	$newsXMLtempF = FileOpen($newestF,0)
	$newsXMLtemp = FileRead($newsXMLtempF)
	FileClose($newestF)
	$newsXML = StringReplace($newsXMLtemp,"&#039;","'")
	$newsArray = StringSplit($newsXML,@LF,3)
	for $f = 0 to UBound($newsArray)-1
		$newsTitleA = _StringBetween($newsArray[$f],"<title>","</title>")
		if not @error then
			$newsTitle = $newsTitleA[0]
		EndIf
		$newsLinkA = _StringBetween($newsArray[$f],"<link>","</link>")
		if not @error then
			$newsLink = $newsLinkA[0]
		EndIf
		$newsDescA = _StringBetween($newsArray[$f],"<description>","<!-- more -->")
		if not @error then
			$newsDesc = $newsDescA[0]
		EndIf
		if $newsArray[$f] = @TAB&@TAB&"</item>" Then
			$newsAdd = $newsTitle&"|"&$newsDesc&"|"&$newsLink
			_ArrayAdd($newsClean,$newsAdd)
		EndIf
	next
	LogActivities("Populate News")
	ShuffleNews()
EndFunc

Func ShuffleNews()
	_ArrayShuffle($newsClean)
	for $f = 0 to 4
		GUICtrlSetData($news[$f],$newsClean[$f][0])
		if $debug[1] = 0 then
			$return = DllCall("quricol32.dll","none", "GenerateBMP","str", "News\QRCodes\link"&$f&".bmp", "str", $newsClean[$f][2],"int",4,"int",2)
			Sleep(100)
			_InvertFile("News\QRCodes\link"&$f&".bmp","inv-")
			Sleep(100)
		EndIf
	Next
	GUICtrlSetImage($newsQRC,"News\QRCodes\inv-link"&$newsNow&".bmp")
	GUICtrlSetData($newsExp,$newsClean[$newsNow][1])
	LogActivities("Shuffle news")
EndFunc

Func RefreshNews()
	$newsNow = $newsNow + 1
	GUICtrlSetColor ($news[mod($newsNow-1,5)],$cor2)
	GUICtrlSetColor ($news[mod($newsNow,5)],$cor1)
	if $newsNow > 4 then $newsNow = 0
	GUICtrlSetImage($newsQRC,"News\QRCodes\inv-link"&mod($newsNow,5)&".bmp")
	GUICtrlSetData($newsExp,$newsClean[mod($newsNow,5)][1])
EndFunc

; Calendar
Func PopulateCalendar()
	for $f = 0 to  4
		GUICtrlSetData($cal[$f][0],"")
		GUICtrlSetData($cal[$f][1],"")
	Next
	GUICtrlSetData($cal[5][1],"")
	GUICtrlSetData($cal[5][0],"")
	Global $calText, $calInfo[0][2]
	if $debug[4] = 0 Then
		$wildcard = "calendar/cal-"&StringReplace(_NowCalcDate(),"/","_")&".txt"
		_FTP_DirSetCurrent ( $hConn, "/<Server FTP>/iSpelho/" )
		_FTP_FileGet($hConn,$wildcard,$wildcard)
	Else
		$wildcard = LeMaisRecente("calendar/","cal-*.txt")
	EndIf
	_FileReadToArray ($wildcard, $calInfo,4,"-|-")
	$calTot = UBound($calInfo)-1
	if not @error and UBound($calInfo) > 0 Then
		for $f = 0 to $calTot
			_Date_Time_Convert_Set("lmo", "January,February,March,April,May,June,July,August,September,October,November,December")
			$calInfo[$f][3] = _Date_Time_Convert($calInfo[$f][3],"MMMM dd, yyyy at hh:mmTT","yyyyMMddHHmm")
			_Date_Time_Convert_Set("lmo", "january,february,march,april,may,june,july,august,september,october,november,december")
		Next
		_ArraySort($calInfo,0,0,0,3)
		Global $calIni = 0
		if $calTot > 4 then
			$calTot = 4
			GUICtrlSetData($cal[5][0],"...")
		EndIf
		for $f = 0 to  $calTot
			$calHora = _Date_Time_Convert($calInfo[$f][3],"yyyyMMddHHmm","HH:mm")
			if $calHora = "00:**" Then
				$calHora = ""
				GUICtrlSetPos($cal[$f][1],$calX)
			Else
				GUICtrlSetPos($cal[$f][1],$calX+65)
			EndIf
			GUICtrlSetData($cal[$f][0],$calHora)
			GUICtrlSetData($cal[$f][1],$calInfo[$f][0])
		Next
	EndIf
	LogActivities("Populate calendar")
EndFunc

Func RefreshCalendar()
	if UBound($calInfo)-1 > 4 Then
		$calIni += 1
		if $calIni + 4 > UBound($calInfo)-1 Then $calIni = 0
		for $f = 0 to 4
			$calHora =_Date_Time_Convert($calInfo[$f+$calIni][3],"yyyyMMddHHmm","HH:mm")
			if $calHora = "00:**" Then
				$calHora = ""
				GUICtrlSetPos($cal[$f][1],$calX)
			Else
				GUICtrlSetPos($cal[$f][1],$calX+65)
			EndIf
			GUICtrlSetData($cal[$f][0],$calHora)
			GUICtrlSetData($cal[$f][1],$calInfo[$f+$calIni][0])
		Next
		if $calIni > 0 Then
			GUICtrlSetData($cal[5][1],"...")
		Else
			GUICtrlSetData($cal[5][1],"")
		EndIf
		if $calIni + 4 < UBound($calInfo)-1 Then
			GUICtrlSetData($cal[5][0],"...")
		Else
			GUICtrlSetData($cal[5][0],"")
		EndIf
	EndIf
EndFunc

; Weather
Func PopulateWeather()
	Global $wSavY = @YEAR,  $wSavM = @MON, $wSavD = @MDAY, $wSavH = @HOUR
	Global $tApTimerDelay = 15000
	if $debug[2] = 0 Then
		Global $weathJson = BinaryToString(InetRead("https://api.darksky.net/forecast/<Key>/<latitude>,%20<longitude>?units=ca&exclude=minutely,alerts,flags&lang=pt"), 4)
		$weathJsonF = FileOpen("ForecastIo\fore-"&$wSavY&"_"&$wSavM&"_"&$wSavD&"-"&$wSavH&".txt",2)
		FileWrite($weathJsonF,$weathJson)
		FileClose($weathJsonF)
	EndIf
	$newest = LeMaisRecente("ForecastIo/","fore-*.txt")
	$weathJsonF = FileOpen($newest,0)
	$weathJson = FileRead($weathJsonF)
	FileClose($weathJsonF)
	$weathLimpo = StringReplace($weathJson,"""","'")
	$horadiaBase = _StringBetween($weathLimpo,"'data':[","}]}")

	$wDatadiff = 0
	$wDataCalc = _EpochToHuman(_StringBetween($weathLimpo,"'time':",",")[0]-10800,"yyyy/MM/dd HH:mm:ss")
	$wDatadiff = _DateDiff("h",$wDataCalc,_NowCalc())

	if $wDatadiff < 1 Then
		$weathWind = _StringBetween($weathLimpo,"'windSpeed':",",")[0]
;~ 		$weathDist = _StringBetween($weathLimpo,"'visibility':",",")[0]
		$weathHumi = _StringBetween($weathLimpo,"'humidity':",",")[0]
		$weathCover = _StringBetween($weathLimpo,"'cloudCover':",",")[0]
		$weathPrecP = _StringBetween($weathLimpo,"'precipProbability':",",")[0]
		$weathPrecI = _StringBetween($weathLimpo,"'precipIntensity':",",")[0]
		$weathIcon = _StringBetween($weathLimpo,"'icon':'","',")[0]
		Global $weathTemp = _StringBetween($weathLimpo,"'temperature':",",")[0]
		Global $weathTAppa = _StringBetween($weathLimpo,"'apparentTemperature':",",")[0]
		GUICtrlSetImage($wLtimeDlyP,"WeatherIcons\blank.jpg")
		GUICtrlSetData($wLtimeDlyN,"")
	Else
		$weathWind = _StringBetween($horadiaBase[0],"'windSpeed':",",")[$wDatadiff]
;~ 		$weathDist = _StringBetween($horadiaBase[0],"'visibility':",",")[$wDatadiff]
		$weathHumi = _StringBetween($horadiaBase[0],"'humidity':",",")[$wDatadiff]
		$weathCover = _StringBetween($horadiaBase[0],"'cloudCover':",",")[$wDatadiff]
		$weathPrecP = _StringBetween($horadiaBase[0],"'precipProbability':",",")[$wDatadiff]
		$weathPrecI = _StringBetween($horadiaBase[0],"'precipIntensity':",",")[$wDatadiff]
		$weathIcon = _StringBetween($horadiaBase[0],"'icon':'","',")[$wDatadiff]
		Global $weathTemp = _StringBetween($horadiaBase[0],"'temperature':",",")[$wDatadiff]
		Global $weathTAppa = _StringBetween($horadiaBase[0],"'apparentTemperature':",",")[$wDatadiff]
		GUICtrlSetImage($wLtimeDlyP,"WeatherIcons\TimeDelay-35.jpg")
		GUICtrlSetData($wLtimeDlyN,$wDatadiff)
	EndIf
	GUICtrlSetData($wLwind,Round($weathWind,1))
;~ 	GUICtrlSetData($wLdist,Round($weathDist,1))
	GUICtrlSetData($wLhum,$weathHumi*100)
	GUICtrlSetData($wLcover,$weathCover*100)
	GUICtrlSetData($wLprepP,$weathPrecP*100)
	GUICtrlSetData($wLprepI,Round($weathPrecI,1))
	GUICtrlSetImage($wLcond,"WeatherIcons\"&$weathIcon&"-80.jpg")
	GUICtrlSetData($wLtempe,Round($weathTemp,0)&"º")

	$saida = _StringBetween($horadiaBase[1],"sunsetTime':",",")
	$weathSunS = _EpochToHuman($saida[0]-10800,"HH:mm")
	$saida = _StringBetween($horadiaBase[1],"sunriseTime':",",")
	$weathSunR = _EpochToHuman($saida[0]-10800,"HH:mm")
	$saida = _StringBetween($horadiaBase[1],"sunriseTime':",",")
	$weathSunRn = _EpochToHuman($saida[1]-10800,"HH:mm")
	if @HOUR <= StringLeft($weathSunR,2) Then
		GUICtrlSetData($wLsuns,$weathSunR)
		GUICtrlSetImage($wLsunsPic,"WeatherIcons\sunrise-30.jpg")
	Elseif @HOUR <= StringLeft($weathSunS,2) Then
		GUICtrlSetData($wLsuns,$weathSunS)
		GUICtrlSetImage($wLsunsPic,"WeatherIcons\sunset-30.jpg")
	Else
		GUICtrlSetData($wLsuns,$weathSunRn)
		GUICtrlSetImage($wLsunsPic,"WeatherIcons\sunrise-30.jpg")
	EndIf

	$saida = _StringBetween($horadiaBase[0],"'icon':'","',")
 	$weathFIcon3 = $saida[3+$wDatadiff]
	$saida = _StringBetween($horadiaBase[0],"'temperature':",",")
	$weathFTemp3 = $saida[3+$wDatadiff]
	$saida = _StringBetween($horadiaBase[0],"'time':",",")
	$weathFHora3 = _EpochToHuman($saida[3+$wDatadiff]-10800,"HH:mm")
	$saida = _StringBetween($horadiaBase[0],"'precipProbability':",",")
	$weathFPrecP3 = $saida[3+$wDatadiff]*100
	GUICtrlSetImage($wLnextCond3,"WeatherIcons\"&$weathFIcon3&"-28.jpg")
	GUICtrlSetData($wLnextProb3,$weathFPrecP3&"%")
	GUICtrlSetData($wLnextTemp3,Round($weathFTemp3,0)&"º")
	GUICtrlSetData($wLnextHour3,"at "&$weathFHora3)

	$saida = _StringBetween($horadiaBase[0],"'icon':'","',")
	$weathFIcon6 = $saida[6+$wDatadiff]
	$saida = _StringBetween($horadiaBase[0],"'temperature':",",")
	$weathFTemp6 = $saida[6+$wDatadiff]
	$saida = _StringBetween($horadiaBase[0],"'time':",",")
	$weathFHora6 = _EpochToHuman($saida[6+$wDatadiff]-10800,"HH:mm")
	$saida = _StringBetween($horadiaBase[0],"'precipProbability':",",")
	$weathFPrecP6 = $saida[6+$wDatadiff]*100
	GUICtrlSetImage($wLnextCond6,"WeatherIcons\"&$weathFIcon6&"-28.jpg")
	GUICtrlSetData($wLnextProb6,$weathFPrecP6&"%")
	GUICtrlSetData($wLnextTemp6,Round($weathFTemp6,0)&"º")
	GUICtrlSetData($wLnextHour6,"at "&$weathFHora6)

	$saida = _StringBetween($horadiaBase[1],"'moonPhase':",",")
	$weathLuadia = $saida[0]*100
	GUICtrlSetImage($wLluaDia,"WeatherIcons\Lua-60\Lua-60_0"&$weathLuadia&".jpg")

	$saidaD = _StringBetween($horadiaBase[1],"'time':",",")
	$saidaI = _StringBetween($horadiaBase[1],"'icon':'","',")
	$saidaTi = _StringBetween($horadiaBase[1],"'temperatureMin':",",")
	$saidaTa = _StringBetween($horadiaBase[1],"'temperatureMax':",",")
	$saidaL = _StringBetween($horadiaBase[1],"'moonPhase':",",")

	for $f = 1 to 5
		$weathFDia = _EpochToHuman($saidaD[$f],"ddd")
		$weathFIcon = $saidaI[$f]
		$weathFTempI = Round($saidaTi[$f],0)
		$weathFTempA = Round($saidaTa[$f],0)
		$weathFTLua = $saidaL[$f]*100
		GUICtrlSetData($wLfore[$f-1][0],$weathFDia)
		GUICtrlSetImage($wLfore[$f-1][1],"WeatherIcons\"&$weathFIcon&"-28.jpg")
		GUICtrlSetData($wLfore[$f-1][2],$weathFTempA)
		GUICtrlSetData($wLfore[$f-1][3],$weathFTempI)
		GUICtrlSetImage($wLfore[$f-1][4],"WeatherIcons\Lua-28\Lua-28_"&StringFormat("%03s",$weathFTLua)&".jpg")
	Next
	LogActivities("Populate weather main")
EndFunc

Func RefreshWeather()
	if $tApTimerDelay = 15000 Then
		GUICtrlSetData($wLtempe,Round($weathTAppa,0)&"º")
		GUICtrlSetImage($wLtAppa,"WeatherIcons\TempAppar.jpg")
		$tApTimerDelay = 5000
	Else
		GUICtrlSetData($wLtempe,Round($weathTemp,0)&"º")
		GUICtrlSetImage($wLtAppa,"WeatherIcons\blank.jpg")
		$tApTimerDelay = 15000
	EndIf
EndFunc

; Lend
Func PopulateEmprestimos()
	for $f = 0 to  4
		GUICtrlSetData($empL[$f][0],"")
		GUICtrlSetData($empL[$f][1],"")
		GUICtrlSetData($empL[$f][2],"")
		GUICtrlSetData($empL[$f][3],"")
	Next
	GUICtrlSetData($empL[5][1],"")
	GUICtrlSetData($empL[5][0],"")
	Global $empInfo[0][4],$saida
	if $debug[6] = 0 Then
		$empFileList = _FileListToArray ("Emprestimos", "emp-*.txt")
		For $f = 0 to UBound($empFileList)-1
			FileMove("Emprestimos/"&$empFileList,"Emprestimos/Done/"&$empFileList,1)
		Next
		_FTP_DirSetCurrent ( $hConn, "/<Server FTP>/iSpelho/emprestimos/" )
		Local $aFile = _FTP_ListToArray($hConn, 0)
		for $f = 1 to $aFile[0]
			_FTP_FileGet($hConn,$aFile[$f],"Emprestimos/"&$aFile[$f])
		Next
	EndIf
	$empFileList = _FileListToArray ("Emprestimos", "emp-*.txt")
	_ArrayDelete($empFileList,0)
	for $f = 0 to UBound($empFileList)-1
		$empTemp = FileRead("Emprestimos\"&$empFileList[$f])
		$saida = StringSplit($empTemp,"-|-",3)
		_ArrayAdd($empInfo,$saida[0])
		$empInfo[$f][1] = _Date_Time_Convert($saida[1],"dd/MM/yyyy","yyyyMMdd")
		$empInfo[$f][2] = $saida[2]
		$empInfo[$f][3] = _DateDiff("d",_Date_Time_Convert($empInfo[$f][1],"yyyyMMdd","yyyy/MM/dd"),_NowCalcDate())
	Next
	_ArraySort($empInfo,0,0,0,1)
	Global $empIni = 0
	$empTot = UBound($empInfo)-1
	if $empTot > 4 Then
		$empTot = 4
		GUICtrlSetData($empL[5][0],"...")
	EndIf
	for $f = 0 to $empTot
		GUICtrlSetData($empL[$f][0],$empInfo[$f][0])
		GUICtrlSetData($empL[$f][1],_Date_Time_Convert($empInfo[$f][1],"yyyyMMdd","d M yy"))
		GUICtrlSetData($empL[$f][2],$empInfo[$f][2])
		GUICtrlSetData($empL[$f][3],$empInfo[$f][3]&" days")
	Next
	LogActivities("Populate Lend")
EndFunc

Func RefreshEmprestimos()
	if UBound($empInfo)-1 > 4 Then
		$empIni += 1
		if $empIni + 4 > UBound($empInfo)-1 Then $empini = 0
		for $f = 0 to 4
			GUICtrlSetData($empL[$f][0],$empInfo[$f+$empIni][0])
			GUICtrlSetData($empL[$f][1],_Date_Time_Convert($empInfo[$f+$empIni][1],"yyyyMMdd","d M yy"))
			GUICtrlSetData($empL[$f][2],$empInfo[$f+$empIni][2])
			GUICtrlSetData($empL[$f][3],$empInfo[$f+$empIni][3]&" days")
		Next
		if $empIni > 0 Then
			GUICtrlSetData($empL[5][1],"...")
		Else
			GUICtrlSetData($empL[5][1],"")
		EndIf
		if $empIni + 4 < UBound($empInfo)-1 Then
			GUICtrlSetData($empL[5][0],"...")
		Else
			GUICtrlSetData($empL[5][0],"")
		EndIf
	EndIf
EndFunc

; Messages
Func PopulateMessages()
	Global $mesSau[0], $mesTit[0], $mesElo[0], $messages[3]
	Global $mesNumAtual = 1, $mesTemMess = False
	_FileReadToArray ("Saudacao/saudacoes.txt",$mesSau,0)
	_FileReadToArray ("Saudacao/titulos.txt",$mesTit,0)
	_FileReadToArray ("Saudacao/elogios.txt",$mesElo,0)
	GUICtrlSetData($mesSauL,$mesSau[Random(0,UBound($mesSau)-1)]&", "&$mesTit[Random(0,UBound($mesTit)-1)]&".")
	GUICtrlSetData($mesEloL,$mesElo[Random(0,UBound($mesElo)-1)])
	if $debug[5] = 0 Then
		$wildcard = "messenger/mes-"&StringReplace(_NowCalcDate(),"/","_")&".txt"
		_FTP_DirSetCurrent ( $hConn, "/<Server FTP>/iSpelho/" )
		_FTP_FileGet($hConn,$wildcard,$wildcard)
	Else
		$wildcard = LeMaisRecente("Messenger/","mes-*.txt")
	EndIf
	_FileReadToArray ($wildcard, $messages,4,"-|-")
	if not @error and UBound($messages) > 0 Then
		$mesTemMess = True
		if UBound($messages) > 1 Then
			GUICtrlSetData($mesNumbL,$mesNumAtual&" of "&UBound($messages)&" messages")
		Else
			GUICtrlSetData($mesNumbL,"only one message today")
		Endif
		GUICtrlSetData($mesMessL,$messages[$mesNumAtual-1][0])
		GUICtrlSetData($mesNomeL,$messages[$mesNumAtual-1][2])
	EndIf
	LogActivities("Populate Messages")
EndFunc

Func RefreshMessages()
	if $mesTemMess and UBound($messages) > 1 Then
		$mesNumAtual += 1
		if $mesNumAtual > UBound($messages) Then $mesNumAtual = 1
		GUICtrlSetData($mesNumbL,$mesNumAtual&" of "&UBound($messages)&" messages")
		GUICtrlSetData($mesMessL,$messages[$mesNumAtual-1][0])
		GUICtrlSetData($mesNomeL,$messages[$mesNumAtual-1][2])
	EndIf
EndFunc

; Helper functions
; Log
Func LogActivities($texto)
	FileWrite($logFileName,_NowCalc()&" "&$texto&" "&@CRLF)
	ConsoleWrite(_NowCalc()&" "&$texto&" "&@CRLF)
EndFunc

; Convert time format
Func _EpochToHuman($data,$formato)
   $human = _Date_Time_Convert(_EpochDecrypt($data), "yyyy/MM/dd HH:mm:ss",$formato)
   Return $human
Endfunc

; Load newer
Func LeMaisRecente($folder,$wildcard)
	$search = FileFindFirstFile($folder & $wildcard)
	$newest = ""
	$now = 0
	While 1
		$file = FileFindNextFile($search)
		if @error Then ExitLoop
		if FileGetTime($folder & $file,0,1) > $now Then
			$now = FileGetTime($folder & $file,0,1)
			$newest = $folder & $file
		EndIf
	WEnd
	Return $newest
EndFunc

; Make transparent
Func _GuiCtrlMakeTrans($iCtrlID,$iTrans=255)
    Local $pHwnd, $nHwnd, $aPos, $a
    $hWnd = GUICtrlGetHandle($iCtrlID);Get the control handle
    If $hWnd = 0 then Return SetError(1,1,0)
    $pHwnd = DllCall("User32.dll", "hwnd", "GetParent", "hwnd", $hWnd);Get the parent Gui Handle
    If $pHwnd[0] = 0 then Return SetError(1,2,0)
    $aPos = ControlGetPos($pHwnd[0],"",$hWnd);Get the current pos of the control
    If @error then Return SetError(1,3,0)
    $nHwnd = GUICreate("", $aPos[2], $aPos[3], $aPos[0], $aPos[1], 0x80000000, 0x00080000 + 0x00000040, $pHwnd[0]);greate a gui in the position of the control
    If $nHwnd = 0 then Return SetError(1,4,0)
    $a = DllCall("User32.dll", "hwnd", "SetParent", "hwnd", $hWnd, "hwnd", $nHwnd);change the parent of the control to the new gui
    If $a[0] = 0 then Return SetError(1,5,0)
    If NOT ControlMove($nHwnd,'',$hWnd,0,0) then Return SetError(1,6,-1);Move the control to 0,0 of the newly created child gui
    GUISetState(@SW_Show,$nHwnd);show the new child gui
    WinSetTrans($nHwnd,"",$iTrans);set the transparency
    If @error then Return SetError(1,7,0)
    GUISwitch($pHwnd[0]);switch back to the parent Gui
    Return $nHwnd;Return the handle for the new Child gui
EndFunc

; Download cartoons
Func BaixaCartoons()
	if $debug[8] = 0 Then
		$cartXjson = BinaryToString(InetRead("http://xkcd.com/info.0.json"), 4); /"&Random(300,1694,1)&"
		$cartXlimpo = StringReplace($cartXjson,"""","'")
		$cartXurl = _StringBetween($cartXlimpo,"'img': '","', 'title'")[0]
		$cartXurl = StringReplace($cartXurl,"\/","/")
		InetGet($cartXurl,"Cartoon\xkcd.png")

	 	$cartSjson = BinaryToString(InetRead("http://www.smbc-comics.com/rss.php"), 4)
	 	$cartSlimpo = StringReplace($cartSjson,"""","'")
	 	$cartSurl = _StringBetween($cartSlimpo,"<img src='","'>")[0]; Random(0,19,1)
	 	$cartSurl = StringReplace($cartSurl,"comicsthumbs","comics")
		InetGet($cartSurl,"Cartoon\smbc.png")
	EndIf
EndFunc

; Apply images
Func AplicaImagens()
	_GDIPlus_GraphicsClear($hGraphic)
	$hGraphic = _GDIPlus_GraphicsCreateFromHWND($GuiCart)

;~ 	Global $xkRand = Random(0,5,1)
	$xkImage = _GDIPlus_ImageLoadFromFile("Cartoon\xkcd.png")
	If @error Then ConsoleWrite("XKCD not found?")
	$xkX = _GDIPlus_ImageGetWidth($xkImage)
	$xkY = _GDIPlus_ImageGetHeight($xkImage)
	Global $xkAR = Round($xkX/$xkY,2)

;~ 	Global $smRand = Random(0,5,1)
;~ 	Global $smRand = 1 ; TESTE
	$smImage = _GDIPlus_ImageLoadFromFile("Cartoon\smbc.png")
	If @error Then ConsoleWrite("SMBC not found?")
	$smX = _GDIPlus_ImageGetWidth($smImage)
	$smY = _GDIPlus_ImageGetHeight($smImage)
	Global $smAR = Round($smX/$smY,2)

	if $smAR <= 0.33 Then ; SMBC too high
		$smPh = $sizeY-20
		$smPw = $smPh*$smAR
		_GDIPlus_GraphicsDrawImageRect($hGraphic, $smImage,10,10,$smPw,$smPh)
		$xkPw = $sizeX-10-($smPw)-10-10
		$xkPh = $xkPw/$xkAR
		_GDIPlus_GraphicsDrawImageRect($hGraphic, $xkImage,10+$smPw+10,($sizeY/2)-($xkPh/2),$xkPw,$xkPh)
		; Consider XKCD's height being higher than SMBC's and make an IF accordingly
	ElseIf $smAR > 0.33 and $xkAR <= 0.5 Then ; SMBC not so high e XKCD high
		$smPw = ($sizeX/2)-15
		$smPh = $smPw/$smAR
		_GDIPlus_GraphicsDrawImageRect($hGraphic, $smImage,10,($sizeY/2)-($smPh/2),$smPw,$smPh)
		$xkPw = ($sizeX/2)-15
		$xkPh = $xkPw/$xkAR
		_GDIPlus_GraphicsDrawImageRect($hGraphic, $xkImage,($sizeX/2)+6,($sizeY/2)-($xkPh/2),$xkPw,$xkPh)
	ElseIf $smAR > 0.33 and $xkAR >= 2 Then ; SMBC not so high e XKCD long
		$xkPw = $sizeX-20
		$xkPh = $xkPw/$xkAR
		_GDIPlus_GraphicsDrawImageRect($hGraphic, $xkImage,10,10,$xkPw,$xkPh)
		$smPh = $sizeY-10-$xkPh-10-10
		$smPw = $smPh*$smAR
		_GDIPlus_GraphicsDrawImageRect($hGraphic, $smImage,($sizeX/2)-($smPw/2),10+$xkPh+10,$smPw,$smPh)
	Else
		if $smAR < $xkAR Then ; SMBC higher than XKCD
			$xkPh = ($sizeY/3)-15
			$xkPw = $xkPh*$xkAR
			_GDIPlus_GraphicsDrawImageRect($hGraphic, $xkImage,($sizeX/2)-($xkPw/2),10,$xkPw,$xkPh)
			$smPh = $sizeY-($sizeY/3)-15
			$smPw = $smPh*$smAR
			_GDIPlus_GraphicsDrawImageRect($hGraphic, $smImage,($sizeX/2)-($smPw/2),10+$xkPh+10,$smPw,$smPh)
		Else
			$xkPh = ($sizeY/2)-15
			$xkPw = $xkPh*$xkAR
			_GDIPlus_GraphicsDrawImageRect($hGraphic, $xkImage,($sizeX/2)-($xkPw/2),10,$xkPw,$xkPh)
			$smPh = ($sizeY/2)-15
			$smPw = $smPh*$smAR
			_GDIPlus_GraphicsDrawImageRect($hGraphic, $smImage,($sizeX/2)-($smPw/2),10+$xkPh+10,$smPw,$smPh)
		EndIf
	EndIf
	_GDIPlus_ImageDispose ($xkImage)
	_GDIPlus_ImageDispose ($smImage)
	LogActivities("Apply Cartoons")
EndFunc

; Refresh map
Func RefreshMap()
	if $debug[9] = 0 Then
		_IEAction($OBJECT, "refresh")
;~ 		_WinAPI_SetWindowPos($GuiMaps,$HWND_TOP,$posXdef,10,0,0,BitOR($SWP_NOSIZE,$SWP_NOACTIVATE))
;~ 		sleep(1000)
;~ 		GUISwitch($Gui)
;~ 		WinActivate($Gui)
	EndIf
	LogActivities("Refresh Map")
EndFunc

; Turn off monitor
Func ApagaMonitor()
	if $acende = False Then
		FileRead("Camera\detecta.jpg")
		if not @error Then ; TEM
			_Monitor(1) ;Turn on monitor
			LogActivities("Turn on")
			$acende = True
			$acendeCont = _Date_Time_GetTickCount()
			Sleep(300)
		EndIf
	EndIf
	if _Date_Time_GetTickCount() > $acendeCont + 300000 and $acende = True Then
		FileRead("Camera\detecta.jpg")
		if not @error Then ; TEM
			FileDelete("Camera\detecta.jpg")
		Else
			_Monitor(0) ;Turn off monitor
			LogActivities("Turn off")
			$acende = False
		EndIf
		$acendeCont = _Date_Time_GetTickCount()
	EndIf
EndFunc

Func _Monitor($run = 1)
    Local $Progman_hwnd = WinGetHandle('[CLASS:Progman]')

    If $run = 0 Then
        BlockInput(1)
        DllCall('user32.dll', 'int', 'SendMessage', _
                'hwnd', $Progman_hwnd, _
                'int', $lciWM_SYSCommand, _
                'int', $lciSC_MonitorPower, _
                'int', $lciPower_Off)
        Return 1
    ElseIf $run = 1 Then
        BlockInput(0)
        DllCall('user32.dll', 'int', 'SendMessage', _
                'hwnd', $Progman_hwnd, _
                'int', $lciWM_SYSCommand, _
                'int', $lciSC_MonitorPower, _
                'int', $lciPower_On)
        Return 1
    EndIf
    Return 0
EndFunc   ;==>_Monitor
