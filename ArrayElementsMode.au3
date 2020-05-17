#include <array.au3> ; Only for _ArrayDisplay()

;~ ; For this array, the mode element is "def" which occurs 3 times
;~ Dim $sTest = "abc,def,ghi,jkl,mno,pqr,stu,vwx,yz1,234,567,890,def,mno,def"
;~ Dim $avTest = StringSplit($sTest, ",")
;~ $avResult = _ArrayElements($avTest, 1)
;~ _ArrayDisplay($avResult, "_ArrayElements()")
;~ $avResult = _ArrayMode($avTest, 1)
;~ _ArrayDisplay($avResult, "_ArrayMode()")

;~ ; For this array, the mode elements are "def", and "pqr" which occur 3 times each
;~ $sTest = "abc,def,ghi,jkl,mno,pqr,stu,vwx,yz1,234,567,890,def,mno,pqr,def,567,pqr,234"
;~ $avTest = StringSplit($sTest, ",")
;~ $avResult = _ArrayElements($avTest, 1)
;~ _ArrayDisplay($avResult, "_ArrayElements()")
;~ $avResult = _ArrayMode($avTest, 1)
;~ _ArrayDisplay($avResult, "_ArrayMode()")

;===============================================================================
; FunctionName:     _ArrayElements()
; Description:      Returns the number of unique elements from a 1D or 2D array
; Syntax:           _ArrayElements( $aArray, $iStart )
; Parameter(s):     $aArray - ByRef array to return unique elements from (array is not changed)
;                   $iStart - (Optional) Index to start at, default is 0
; Return Value(s):  On success returns an array of unique elements,  $aReturn[0] = count
;                   On failure returns 0 and sets @error (see code below)
; Author(s):        jon8763; Modified by PsaltyDS
;===============================================================================
Func _ArrayElements(ByRef $aArray, $iStart = 0)
    If Not IsArray($aArray) Then Return SetError(1, 0, 0)

    ; Setup to use SOH as delimiter
    Local $SOH = Chr(01), $sData = $SOH

    ; Setup for number of dimensions
    Local $iBound1 = UBound($aArray) - 1, $Dim2 = False, $iBound2 = 0
    Select
        Case UBound($aArray, 0) = 2
            $Dim2 = True
            $iBound2 = UBound($aArray, 2) - 1
        Case UBound($aArray, 0) > 2
            Return SetError(2, 0, 0)
    EndSelect

    ; Get list of unique elements
    For $m = $iStart To $iBound1
        If $Dim2 Then
            ; 2D
            For $n = 0 To $iBound2
                If Not StringInStr($sData, $SOH & $aArray[$m][$n] & $SOH) Then $sData &= $aArray[$m][$n] & $SOH
            Next
        Else
            ; 1D
            If Not StringInStr($sData, $SOH & $aArray[$m] & $SOH) Then $sData &= $aArray[$m] & $SOH
        EndIf
    Next

    ; Strip start and end delimiters
    $sData = StringTrimRight(StringTrimLeft($sData, 1), 1)

    ; Return results after testing for null set
    Local $avRET = StringSplit($sData, $SOH)
    If $avRET[0] = 1 And $avRET[1] = "" Then Local $avRET[1] = [0]
    Return $avRET
EndFunc   ;==>_ArrayElements

;===============================================================================
;
; FunctionName:     _ArrayMode()
; Description:      Returns the most frequently occuring elements in the array
; Syntax:           _ArrayMode( $aArray [, $iStart] )
; Parameter(s):     $aArray - The ByRef array to find the mode of
;                   $iStart - (optional) The first index to check for data, default is 0
; Return Value(s):  On success returns a 1D array:
;                       [0] = Mode (number of instances of most common data element)
;                       [1] = First mode element
;                       [2] = Second mode element (with same mode count as first)
;                       [n] = Last mode element (with same mode count as first)
;                   On failure returns 0 and sets @error
; Author(s):        jon8763; modified by PsaltyDS
;===============================================================================
Func _ArrayMode(ByRef $aArray, $iStart = 0)
    ; Get list of unique elements
    Local $aData = _ArrayElements($aArray, $iStart)
    If @error Then Return SetError(@error, 0, 0)
    If $aData[0] = 0 Then Return $aData

    ; Setup to use SOH as delimiter
    Local $SOH = Chr(01), $sData = $SOH

    ; Setup for number of dimensions
    Local $iBound1 = UBound($aArray) - 1, $Dim2 = False, $iBound2 = 0
    If UBound($aArray, 0) = 2 Then
        $Dim2 = True
        $iBound2 = UBound($aArray, 2) - 1
    EndIf

    ; Assemble data string for searching
    For $m = $iStart To $iBound1
        If $Dim2 Then
            ; 2D
            For $n = 0 To $iBound2
                $sData &= $aArray[$m][$n] & $SOH
            Next
        Else
            ; 1D
            $sData &= $aArray[$m] & $SOH
        EndIf
    Next

    ; Check count of each unique element listed in $aData, highest count kept in $aCounts[0]
    Local $aCounts[$aData[0] + 1] = [0], $aRegExp[1]
    For $n = 1 To $aData[0]
        $aRegExp = StringRegExp($sData, $SOH & $aData[$n] & $SOH, 3)
        $aCounts[$n] = UBound($aRegExp)
        If $aCounts[$n] > $aCounts[0] Then $aCounts[0] = $aCounts[$n]
    Next

    ; Count elements that match the mode number
    Local $iMatches = 0
    For $n = 1 To $aData[0]
        If $aCounts[$n] = $aCounts[0] Then $iMatches += 1
    Next

    ; Return all elements matching highest count
    Local $aRET[$iMatches + 1] = [$aCounts[0]], $m = 1
    For $n = 1 To $aData[0]
        ; Add elements where count matches mode
        If $aCounts[$n] = $aCounts[0] Then
            $aRET[$m] = $aData[$n]
            $m += 1
        EndIf
    Next
    Return $aRET
EndFunc   ;==>_ArrayMode