Sub CalculateMaintenanceCounters()
Dim db As Database, rs As Recordset, rsMore As Recordset
Dim lngDeltaBW As Long, lngDeltaC As Long
Dim bNullCounter As Boolean, bColor As Boolean
bColor = varCurrentEquipmentStats(1)
Set db = CurrentDb
'
'   Check for MAIN MAINTENANCE counters; if they are non-null, calculate; otherwise look for TOTAL counters
'
Set rs = db.OpenRecordset("SELECT tblTempCounters.CurrentReading, tblTempCounters.PreviousReading, tblTempCounters.CounterCode " _
    & "FROM tblTempCounters " _
    & "WHERE ((tblTempCounters.CounterCode) = ""TA"" Or (tblTempCounters.CounterCode) = ""CA"") Or ((tblTempCounters.CounterCode) = ""MREQ"");")
If rs.RecordCount > 0 Then
    bNullCounter = False
    Do Until bNullCounter Or rs.EOF
        If ((rs!CurrentReading) = 0) Then bNullCounter = True
        rs.MoveNext
    Loop
    If bNullCounter Then
        If bColor Then
            Set rsMore = db.OpenRecordset("SELECT tblTempCounters.CurrentReading, tblTempCounters.CounterCode, tblTempCounters.PreviousReading " _
                & "FROM tblTempCounters " _
                & "WHERE ((tblTempCounters.CounterCode) = ""TotBW"" Or (tblTempCounters.CounterCode) = ""TotC"");")
        Else
            Set rsMore = db.OpenRecordset("SELECT tblTempCounters.CurrentReading, tblTempCounters.CounterCode, tblTempCounters.PreviousReading " _
                & "FROM tblTempCounters " _
               & "WHERE ((tblTempCounters.CounterCode) = ""TotBW"");")
        End If
        If rsMore.RecordCount > 0 Then
            bNullCounter = False
            Do Until bNullCounter Or rsMore.EOF
                If ((rsMore!CurrentReading) = 0) Then bNullCounter = True
                rsMore.MoveNext
            Loop
            If bNullCounter Then
                MsgBox "Well... give me something to start with; in order to calculate PM counters, I need" _
                    & vbNewLine & "either TOTAL counters or MAIN MAINTENANCE counters." _
                    & vbNewLine & "Try again when you have some data!", vbOKOnly, "I say..."
            Else
                'calculate on TOTAL
                lngDeltaBW = 0
                lngDeltaC = 0
                rsMore.MoveFirst
                Do Until rsMore.EOF
                    Select Case (rsMore!CounterCode)
                        Case "TotBW"
                            lngDeltaBW = rsMore!CurrentReading - rsMore!PreviousReading
                        Case "TotC"
                            lngDeltaC = rsMore!CurrentReading - rsMore!PreviousReading
                    End Select
                    rsMore.MoveNext
                Loop
            End If
        End If
        rsMore.Close
    Else
        'calculate on MAINTENANCE
        lngDeltaBW = 0
        lngDeltaC = 0
        rs.MoveFirst
        Do Until rs.EOF
            Select Case (rs!CounterCode)
                Case "CA"
                    lngDeltaC = rs!CurrentReading - rs!PreviousReading
                Case "MREQ"
                    lngDeltaBW = rs!CurrentReading - rs!PreviousReading
            End Select
            rs.MoveNext
        Loop
        rs.MoveFirst
        Do Until rs.EOF
            Select Case (rs!CounterCode)
                Case "TA"
                    lngDeltaBW = rs!CurrentReading - rs!PreviousReading - lngDeltaC
            End Select
            rs.MoveNext
        Loop
    End If
Else
    'Debug.Print "There is no TempCounters table..."
End If
rs.Close
'
'   Do actual calculation...
'
If Not bNullCounter Then
    Set rs = db.OpenRecordset("SELECT tblTempCounters.* " _
        & "FROM tblTempCounters " _
        & "WHERE (((tblTempCounters.CounterCode) Not Like ""Tot*"")) " _
        & "ORDER BY tblTempCounters.CounterNumber;")
    Do Until rs.EOF
        Select Case rs!CounterColor
            Case "BW"
                rs.Edit
                rs!CurrentReading = rs!PreviousReading + lngDeltaBW
                rs.Update
            Case "COLOR"
                rs.Edit
                rs!CurrentReading = rs!PreviousReading + lngDeltaC
                rs.Update
            Case "ALL"
                rs.Edit
                rs!CurrentReading = rs!PreviousReading + (lngDeltaBW + lngDeltaC)
                rs.Update
        End Select
        rs.MoveNext
    Loop
    rs.Close
End If
Set db = Nothing
End Sub
