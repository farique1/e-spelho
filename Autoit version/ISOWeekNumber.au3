#include <Date.au3>
;===============================================================================
;
; Function Name:  _ISOWeekNumber()
; Description:  Find out the week number of current date OR date given in parameters
;
; Parameter(s):   $Day  - Day value (default = current day)
;               $Month  - Month value (default = current month)

;               $Year   - Year value (default = current year)
;               $Weekstart - Week starts from Sunday (0, default) or Monday (1)
; Requirement(s):   AutoIt3 with _Date UDF's
; Return Value(s):  On Success   - Returns week number of given date
;                  On Failure    - returns -1  and sets @ERROR = 1 on faulty parameters values
;               On non-acceptable weekstart value sets @ERROR = 99 and uses default (Sunday) as starting day
; Author(s):        Tuape
;
;===============================================================================
;
Func _ISOWeekNumber($Day=@MDAY, $Month=@MON, $Year=@YEAR, $WeekStart=0)
    local $firstDay
    Local $diff
   ; Local $WeekStart

; Check for erroneous input in $Day, $Month & $Year
    If  $Day > 31 or $Day < 1 Then
        SetError(1)
        Return -1
    ElseIf $Month > 12 or $Month < 1 Then
        SetError(1)
        Return -1
    ElseIf $Year < 1 or $Year > 2999 Then
        SetError(1)
        Return -1
    EndIf

; check if $WeekStart parameter is ok (= Sun / Mon)
    If Not IsInt($WeekStart) Or $WeekStart > 1 or $WeekStart < 0 Then
        $WeekStart = 0
        SetError(99)
    EndIf

; Find out the first day of real week 1
    $firstDay = _dateToDayOfWeek($Year, 1, 1)

    If $firstDay = 1 Then
        $diff = 1 - $firstDay + $WeekStart
    ElseIf  $firstDay = 2 Then
        $diff = 1 - $firstDay + $WeekStart
    ElseIf $firstDay <= 5 Then
        $diff = 1-$firstDay + $WeekStart
    ElseIf $firstDay > 5 Then
        $diff = 7 - ($firstDay -1) + $WeekStart

    EndIf

    $FirstWeekStart = _DateAdd ( 'd', $diff, $Year & "/01/01")

; Compare to real first day of week 1 and find out the difference in weeks
    If _DateDiff('d', $FirstWeekStart, $Year & "/" & $Month & "/" & $Day) >= 0 Then
        return _DateDiff( 'w',$FirstWeekStart, $Year & "/" & $Month & "/" & $Day) +1
    Else
        return _DateDiff( 'w',$Year-1 & "/01/01", $Year & "/" & $Month & "/" & $Day)
    EndIf

Endfunc