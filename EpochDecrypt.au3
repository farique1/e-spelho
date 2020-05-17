;~  ConsoleWrite(_EpochDecrypt (1463216400)&@CRLF)
;~  _GetDateFromUnix (1463248800)

Func _EpochDecrypt($iEpochTime)

	Local $iDayToAdd = Int($iEpochTime / 86400)
	Local $iTimeVal = Mod($iEpochTime, 86400)

	If $iTimeVal < 0 Then
		$iDayToAdd -= 1
		$iTimeVal += 86400
	EndIf

	Local $i_wFactor = Int((573371.75 + $iDayToAdd) / 36524.25)
	Local $i_xFactor = Int($i_wFactor / 4)
	Local $i_bFactor = 2442113 + $iDayToAdd + $i_wFactor - $i_xFactor

	Local $i_cFactor = Int(($i_bFactor - 122.1) / 365.25)
	Local $i_dFactor = Int(365.25 * $i_cFactor)
	Local $i_eFactor = Int(($i_bFactor - $i_dFactor) / 30.6001)

	Local $aDatePart[3]
	$aDatePart[2] = $i_bFactor - $i_dFactor - Int(30.6001 * $i_eFactor)
	$aDatePart[1] = $i_eFactor - 1 - 12 * ($i_eFactor - 2 > 11)
	$aDatePart[0] = $i_cFactor - 4716 + ($aDatePart[1] < 3)

	Local $aTimePart[3]
	$aTimePart[0] = Int($iTimeVal / 3600)
	$iTimeVal = Mod($iTimeVal, 3600)
	$aTimePart[1] = Int($iTimeVal / 60)
	$aTimePart[2] = Mod($iTimeVal, 60)

	Return SetError(0, 0, StringFormat("%.2d/%.2d/%.2d %.2d:%.2d:%.2d", $aDatePart[0], $aDatePart[1], $aDatePart[2], $aTimePart[0], $aTimePart[1], $aTimePart[2]))

EndFunc   ;==>_EpochDecrypt
