
# Lab 04 - Automated Identity Lifecycle Management
# Phase 1: HR onboarding validation and dry-run preview
# No Active Directory accounts are modified.
# Provisioning safety control
# Leave $false until all validation checks have passed.
$EnableProvisioning = $false

# A separate confirmation is required for real provisioning.
# Keep this false until we deliberately authorize execution.
$ConfirmProvisioning = $false


# Request an initial password only in execution mode

# Require an interactive confirmation before real provisioning
if ($EnableProvisioning -and $ConfirmProvisioning) {
    $confirmation = Read-Host 'Type PROVISION-LAB04 to authorize account creation'

    if ($confirmation -cne 'PROVISION-LAB04') {
        throw "Provisioning cancelled - confirmation phrase did not match."
    }
}

$initialPassword = $null


if ($EnableProvisioning -and $ConfirmProvisioning) {
    Write-Host "EXECUTION MODE ENABLED - AD changes may be performed." -ForegroundColor Yellow

    $initialPassword = Read-Host `
        "Enter a temporary password for the LAB accounts" `
        -AsSecureString

    if ($null -eq $initialPassword -or $initialPassword.Length -eq 0) {
        throw "Provisioning cancelled - no password supplied."
    }
}
else {
    Write-Host "DRY RUN MODE - No AD changes will be performed." -ForegroundColor Green
}


Import-Module ActiveDirectory -ErrorAction Stop


# Create a lab user only when explicitly authorized
function New-IAMLabUser {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Employee,

        [Parameter(Mandatory)]
        [string]$TargetOU,

        [Parameter(Mandatory)]
        [securestring]$InitialPassword
    )

    $username = $Employee.SamAccountName
    $displayName = "$($Employee.FirstName) $($Employee.LastName)"

    if ($PSCmdlet.ShouldProcess($username, "Create Active Directory account")) {
        New-ADUser `
            -Name $displayName `
            -GivenName $Employee.FirstName `
            -Surname $Employee.LastName `
            -DisplayName $displayName `
            -SamAccountName $username `
            -UserPrincipalName "$username@corp.example.test" `
            -EmployeeID $Employee.EmployeeID `
            -Department $Employee.Department `
            -Title $Employee.JobTitle `
            -Path $TargetOU `
            -AccountPassword $InitialPassword `
            -ChangePasswordAtLogon $true `
            -Enabled $false `
            -ErrorAction Stop
    }
}

$csvPath = "C:\IAM-Lab04\HR-Input\HR-Onboarding.csv"
$baseDN = "OU=RodriguezTechnologies,DC=corp,DC=example,DC=test"

# Approved department-to-access mapping
$departmentMap = @{
    "IT" = @{
        OU = "OU=IT,$baseDN"
        Group = "SG_IT_SUPPORT"
    }
    "Finance" = @{
        OU = "OU=Finance,$baseDN"
        Group = "SG_FINANCE"
    }
    "HR" = @{
        OU = "OU=Human Resources,$baseDN"
        Group = "SG_HR"
    }
}

$employees = Import-Csv -Path $csvPath -ErrorAction Stop


# Identify duplicate employee IDs in the HR input file
$duplicateEmployeeIDs = @(
    $employees |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_.EmployeeID) } |
        Group-Object EmployeeID |
        Where-Object { $_.Count -gt 1 } |
        Select-Object -ExpandProperty Name
)


# Identify duplicate usernames within the HR input file
$duplicateUsernames = @(
    $employees |
        Where-Object {
            -not [string]::IsNullOrWhiteSpace($_.SamAccountName)
        } |
        Group-Object SamAccountName |
        Where-Object { $_.Count -gt 1 } |
        Select-Object -ExpandProperty Name
)



$results = foreach ($employee in $employees) {

    $status = ""
    $targetOU = ""
    $targetGroup = ""

    if ($employee.Action -ne "Joiner") {
        $status = "REJECTED - Invalid action"
    }
    elseif ($employee.ApprovalStatus -ne "Approved") {
        $status = "BLOCKED - Approval required"
    }

    
elseif ($duplicateEmployeeIDs -contains $employee.EmployeeID) {
    $status = "REJECTED - Duplicate employee ID"
}


elseif ($duplicateUsernames -contains $employee.SamAccountName) {
    $status = "REJECTED - Duplicate username"
}


    elseif ([string]::IsNullOrWhiteSpace($employee.EmployeeID) -or
            [string]::IsNullOrWhiteSpace($employee.FirstName) -or
            [string]::IsNullOrWhiteSpace($employee.LastName) -or
            [string]::IsNullOrWhiteSpace($employee.SamAccountName)) {
        $status = "REJECTED - Missing required data"
    }
    elseif (-not $departmentMap.ContainsKey($employee.Department)) {
        $status = "REJECTED - Unknown department"
    }
    else {
        
# Check whether the username already exists in AD
$existing = Get-ADUser `
    -Filter "SamAccountName -eq '$($employee.SamAccountName)'" `
    -ErrorAction Stop

# Check whether the employee ID belongs to an existing AD account
$existingID = Get-ADUser `
    -Filter "EmployeeID -eq '$($employee.EmployeeID)'" `
    -Properties EmployeeID `
    -ErrorAction Stop

if ($existing) {
    $status = "BLOCKED - Account already exists"
}
elseif ($existingID) {
    $status = "BLOCKED - Employee ID already exists"
}
else {
    $targetOU = $departmentMap[$employee.Department].OU
    $targetGroup = $departmentMap[$employee.Department].Group
    $status = "DRY RUN - Ready to provision"
}

    }

    [PSCustomObject]@{
        Employee = "$($employee.FirstName) $($employee.LastName)"
        Username = $employee.SamAccountName
        Department = $employee.Department
        TargetOU = $targetOU
        TargetGroup = $targetGroup
        Result = $status
    }
}


# Select only records that passed all onboarding checks
$approvedProvisioningCandidates = @(
    $results | Where-Object {
        $_.Result -eq "DRY RUN - Ready to provision" -and
        -not [string]::IsNullOrWhiteSpace($_.TargetOU) -and
        -not [string]::IsNullOrWhiteSpace($_.TargetGroup)
    }
)

Write-Host ""
Write-Host "Eligible onboarding candidates: $($approvedProvisioningCandidates.Count)" -ForegroundColor Cyan


# Preview approved provisioning actions without changing AD
Write-Host ""
Write-Host "PROVISIONING ACTION PREVIEW" -ForegroundColor Cyan

foreach ($candidate in $approvedProvisioningCandidates) {
    Write-Host "Would create: $($candidate.Username)" -ForegroundColor Yellow
    Write-Host "  Target OU: $($candidate.TargetOU)"
    Write-Host "  Security group: $($candidate.TargetGroup)"
}

Write-Host ""
Write-Host "Preview complete - No accounts created." -ForegroundColor Green


# Track provisioning execution outcomes separately from validation
$provisioningResults = [System.Collections.Generic.List[object]]::new()


# Execution-time revalidation of approved candidates
Write-Host ""
Write-Host "EXECUTION ELIGIBILITY CHECK" -ForegroundColor Cyan

foreach ($candidate in $approvedProvisioningCandidates) {

    $matchingRequests = @(
        $employees | Where-Object {
            $_.SamAccountName -eq $candidate.Username
        }
    )

    if ($matchingRequests.Count -ne 1) {
        Write-Host "BLOCKED: $($candidate.Username) - Ambiguous HR request" -ForegroundColor Red
        continue
    }

    $request = $matchingRequests[0]

    if ($request.ApprovalStatus -ne "Approved" -or
        $request.Action -ne "Joiner") {
        Write-Host "BLOCKED: $($candidate.Username) - Approval/action invalid" -ForegroundColor Red
        continue
    }

    if ($request.Department -ne $candidate.Department -or
        $departmentMap[$request.Department].OU -ne $candidate.TargetOU -or
        $departmentMap[$request.Department].Group -ne $candidate.TargetGroup) {
        Write-Host "BLOCKED: $($candidate.Username) - Access mapping mismatch" -ForegroundColor Red
        continue
    }

    
# Final AD identity collision check
$adUsernameMatch = Get-ADUser `
    -Filter "SamAccountName -eq '$($request.SamAccountName)'" `
    -ErrorAction Stop

$adEmployeeIDMatch = Get-ADUser `
    -Filter "EmployeeID -eq '$($request.EmployeeID)'" `
    -ErrorAction Stop

if ($adUsernameMatch -or $adEmployeeIDMatch) {
    Write-Host "BLOCKED: $($candidate.Username) - Identity already exists in AD" -ForegroundColor Red
    continue
}

    Write-Host "VERIFIED: $($candidate.Username) - Eligible for controlled provisioning" -ForegroundColor Green

    

# Guarded account creation - disabled accounts only
if ($EnableProvisioning -and $ConfirmProvisioning) {
    try {
        # Recheck AD immediately before creation
        $usernameCollision = Get-ADUser `
            -Filter "SamAccountName -eq '$($request.SamAccountName)'" `
            -ErrorAction Stop

        $employeeIDCollision = Get-ADUser `
            -Filter "EmployeeID -eq '$($request.EmployeeID)'" `
            -ErrorAction Stop

        
if ($usernameCollision -or $employeeIDCollision) {
    Write-Host "BLOCKED: $($candidate.Username) - Duplicate identity detected" -ForegroundColor Red

    $provisioningResults.Add([PSCustomObject]@{
        Timestamp  = (Get-Date).ToString("o")
        EmployeeID = $request.EmployeeID
        Username   = $candidate.Username
        TargetOU   = $candidate.TargetOU
        Status     = "BLOCKED_DUPLICATE_IDENTITY"
    })

    continue
}


        New-IAMLabUser `
            -Employee $request `
            -TargetOU $candidate.TargetOU `
            -InitialPassword $initialPassword `
            -Confirm:$false

        # Verify account was created in the correct OU and remains disabled
        $createdUser = Get-ADUser `
            -Identity $request.SamAccountName `
            -Properties EmployeeID, Enabled `
            -ErrorAction Stop

        
if ($createdUser.Enabled -eq $false -and
    $createdUser.EmployeeID -eq $request.EmployeeID -and
    $createdUser.DistinguishedName.EndsWith($candidate.TargetOU)) {

    Write-Host "CREATED AND VERIFIED: $($candidate.Username) - Account disabled" -ForegroundColor Green

    $provisioningResults.Add([PSCustomObject]@{
        Timestamp  = (Get-Date).ToString("o")
        EmployeeID = $request.EmployeeID
        Username   = $candidate.Username
        TargetOU   = $candidate.TargetOU
        Status     = "CREATED_AND_VERIFIED"
    })
}
else {
    Write-Host "REVIEW REQUIRED: $($candidate.Username) - Account attributes need verification" -ForegroundColor Yellow

    $provisioningResults.Add([PSCustomObject]@{
        Timestamp  = (Get-Date).ToString("o")
        EmployeeID = $request.EmployeeID
        Username   = $candidate.Username
        TargetOU   = $candidate.TargetOU
        Status     = "VERIFICATION_FAILED"
    })
}

    }
    
catch {
    $errorMessage = $_.Exception.Message

    Write-Host "ERROR provisioning $($candidate.Username): $errorMessage" -ForegroundColor Red

    $provisioningResults.Add([PSCustomObject]@{
        Timestamp  = (Get-Date).ToString("o")
        EmployeeID = $request.EmployeeID
        Username   = $candidate.Username
        TargetOU   = $candidate.TargetOU
        Status     = "PROVISIONING_ERROR"
    })
}

}
else {
    # Preview only - cannot modify AD
    $previewPassword = New-Object System.Security.SecureString

    New-IAMLabUser `
        -Employee $request `
        -TargetOU $candidate.TargetOU `
        -InitialPassword $previewPassword `
        -WhatIf
}


}


$results | Format-Table Employee, Username, Department, TargetGroup, Result -AutoSize

Write-Host ""

# Display the correct completion message for the selected mode
if ($EnableProvisioning -and $ConfirmProvisioning) {
    Write-Host "EXECUTION MODE COMPLETE - Review provisioning results and verify Active Directory." -ForegroundColor Yellow
}
else {
    Write-Host "DRY RUN COMPLETE - No Active Directory changes made." -ForegroundColor Green
}


# Export onboarding validation results
$reportPath = "C:\IAM-Lab04\Reports\IAM-Onboarding-DryRun.csv"

$results | Export-Csv `
    -Path $reportPath `
    -NoTypeInformation `
    -Encoding UTF8

Write-Host "Validation report exported to: $reportPath" -ForegroundColor Cyan


# Write structured dry-run audit records
$logPath = "C:\IAM-Lab04\Logs\IAM-Onboarding-Audit.csv"
$runId = [guid]::NewGuid().ToString()
$runTime = (Get-Date).ToString("o")
$operator = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$auditRecords = foreach ($result in $results) {
    [PSCustomObject]@{
        RunID       = $runId
        Timestamp   = $runTime
        Operator    = $operator
        Employee    = $result.Employee
        Username    = $result.Username
        Department  = $result.Department
        TargetGroup = $result.TargetGroup
        Result      = $result.Result
        Mode        = "DryRun"
    }
}

if (Test-Path $logPath) {
    $auditRecords | Export-Csv -Path $logPath -Append -NoTypeInformation -Encoding UTF8
}
else {
    $auditRecords | Export-Csv -Path $logPath -NoTypeInformation -Encoding UTF8
}

Write-Host "Audit log updated: $logPath" -ForegroundColor Cyan


# Export actual provisioning execution results
$executionReportPath = "C:\IAM-Lab04\Reports\IAM-Provisioning-Execution.csv"


if ($provisioningResults.Count -gt 0) {

    if (Test-Path $executionReportPath) {
        $provisioningResults |
            Export-Csv -Path $executionReportPath `
                -Append -NoTypeInformation -Encoding UTF8
    }
    else {
        $provisioningResults |
            Export-Csv -Path $executionReportPath `
                -NoTypeInformation -Encoding UTF8
    }

    Write-Host "Execution report updated: $executionReportPath" -ForegroundColor Cyan
}
else {
    Write-Host "No provisioning actions executed - execution report not generated." -ForegroundColor Yellow
}

