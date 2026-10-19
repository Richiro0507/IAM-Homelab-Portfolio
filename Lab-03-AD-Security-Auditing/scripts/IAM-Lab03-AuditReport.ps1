
# IAM Lab 03 - Active Directory Security Auditing
# Scenario: Investigate group membership changes for Sarah Johnson

$events = Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4728, 4729
    StartTime = (Get-Date).AddDays(-7)
}

$report = foreach ($event in $events) {
    [xml]$xml = $event.ToXml()

    $data = @{}
    foreach ($field in $xml.Event.EventData.Data) {
        $data[$field.Name] = $field.'#text'
    }

    if (
        $data['TargetUserName'] -eq 'SG_IT_SUPPORT' -and
        $data['MemberName'] -like '*Sarah Johnson*'
    ) {
        $action = if ($event.Id -eq 4728) {
            'Member Added'
        } else {
            'Member Removed'
        }

        [PSCustomObject]@{
            TimeCreated = $event.TimeCreated
            EventID     = $event.Id
            Action      = $action
            PerformedBy = "$($data['SubjectDomainName'])\$($data['SubjectUserName'])"
            Member      = $data['MemberName']
            Group       = "$($data['TargetDomainName'])\$($data['TargetUserName'])"
        }
    }
}

$report | Sort-Object TimeCreated |
    Format-Table TimeCreated, EventID, Action, PerformedBy, Group -AutoSize


# Export the IAM security audit report to CSV
$csvPath = "C:\IAM-Lab03\IAM-Lab03-IncidentReport.csv"

$report |
    Sort-Object TimeCreated |
    Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "Audit report exported to: $csvPath" -ForegroundColor Green


