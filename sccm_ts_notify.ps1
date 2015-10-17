[CmdletBinding()]
param(
    [string]$MachineName,
    [switch]$Fail,
    [switch]$Success)

If($Success) {
    $successOrFailMsgID = "11171"
    $SuccessorFailure   = "Success"
} else {
    $successOrFailMsgID = "11170"
    $SuccessorFailure   = "Failure"
}

$TimeBeginQuery = "SELECT Time FROM SMS_StatMsgWithInsStrings WHERE MachineName='$MachineName' AND MessageID = '11140'"
$TimeEndQuery   = "SELECT Time FROM SMS_StatMsgWithInsStrings WHERE MachineName='$MachineName' AND MessageID = '$successOrFailMsgID'"
$TimeBegin = [management.managementDateTimeConverter]::ToDateTime($(Get-WmiObject -Namespace root\sms\site_RSC -ComputerName sccm-ps1 -Query $TimeBeginQuery | Select-Object -ExpandProperty Time)[0])
$TimeEnd   = [management.managementDateTimeConverter]::ToDateTime($(Get-WmiObject -Namespace root\sms\site_RSC -ComputerName sccm-ps1 -Query $TimeEndQuery | Select-Object -ExpandProperty Time))


$RecordIDQuery         = "SELECT RecordID FROM SMS_StatMsgWithInsStrings WHERE MachineName='$MachineName' AND MessageID = '11140'"
$RecordID         = (Get-WmiObject -Namespace root\sms\site_RSC -ComputerName sccm-ps1 -Query $RecordIDQuery | Select-Object -ExpandProperty RecordID)[0]
$TaskSequenceIDQuery   = "SELECT AttributeValue FROM SMS_StatMsgAttributes WHERE RecordID='$RecordID' AND AttributeID = '400'"
$TaskSequenceID   = (Get-WmiObject -Namespace root\sms\site_RSC -ComputerName sccm-ps1 -Query $TaskSequenceIDQuery | Select-Object -ExpandProperty AttributeValue)
$TaskSequenceNameQuery = "SELECT Name FROM SMS_TaskSequencePackage WHERE PackageID='$TaskSequenceID'"
$TaskSequenceName = (Get-WmiObject -Namespace root\sms\site_RSC -ComputerName sccm-ps1 -Query $TaskSequenceNameQuery | Select-Object -ExpandProperty Name)


$StatusMsgsQuery = "SELECT * FROM SMS_StatMsgWithInsStrings WHERE MachineName='$MachineName'"
$StatusMsgs      = (Get-WmiObject -Namespace root\sms\site_RSC -ComputerName sccm-ps1 -Query $StatusMsgsQuery | Format-Table Time, MachineName, Component, MessageID, InsString2 | Out-String)


If ($PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent) {
     $DebugPreference="Continue"
     Write-Debug "Debug Output activated"
} Else {
    $DebugPreference="SilentlyContinue"

     
    ## Sending Email ##
    $MailFrom = "SCCM TS Notifications <sccmtsnotify@contoso.com>"
    $MailTo   = "User <user@contoso.com>"
    $MailSMTP = "mail.contoso.com"

    $MailSubject = "TaskSequence [$TaskSequenceName] [$SuccessorFailure]"
    $MailBody = @"

    $TaskSequenceName [$TaskSequenceID]
    Machine: $MachineName
    Begins: $TimeBegin
    Ends: $TimeEnd
    Elapsed: $(New-TimeSpan -start $TimeBegin -end $TimeEnd)

    $StatusMsgs
"@

    Send-MailMessage -from $MailFrom -to $MailTo -subject $MailSubject -body $MailBody -SmtpServer $MailSMTP
    
}
