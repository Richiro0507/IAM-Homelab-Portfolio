
# Lab 04 - Automated RBAC Group Assignment
# Phase 1: Approval validation and dry-run preview
# No Active Directory group memberships are modified.

Import-Module ActiveDirectory -ErrorAction Stop

$EnableGroupAssignment = $false
$ConfirmGroupAssignment = $false


# Require explicit confirmation before changing group memberships
if ($EnableGroupAssignment -and $ConfirmGroupAssignment) {
    $confirmation = Read-Host "Type ASSIGN-LAB04 to authorize RBAC changes"

    if ($confirmation -cne "ASSIGN-LAB04") {
        throw "Group assignment cancelled - confirmation phrase did not match."
    }

    Write-Host "RBAC EXECUTION MODE AUTHORIZED" -ForegroundColor Yellow
}
else {
    Write-Host "RBAC DRY RUN MODE - No group changes authorized." -ForegroundColor Green
}


$csvPath = "C:\IAM-Lab04\HR-Input\HR-Onboarding.csv"
$baseDN = "OU=RodriguezTechnologies,DC=corp,DC=example,DC=test"

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

$employees = @(Import-Csv -Path $csvPath -ErrorAction Stop)


# Detect duplicate employee IDs and usernames in the HR input
$duplicateEmployeeIDs = @(
    $employees |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_.EmployeeID) } |
        Group-Object EmployeeID |
        Where-Object { $_.Count -gt 1 } |
        Select-Object -ExpandProperty Name
)

$duplicateUsernames = @(
    $employees |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_.SamAccountName) } |
        Group-Object SamAccountName |
        Where-Object { $_.Count -gt 1 } |
        Select-Object -ExpandProperty Name
)

$results = foreach ($employee in $employees) {

    $status = ""
    $targetGroup = ""

    if ($employee.Action -ne "Joiner" -or
        $employee.ApprovalStatus -ne "Approved") {
        $status = "BLOCKED - Approval or action invalid"
    }
    elseif ([string]::IsNullOrWhiteSpace($employee.EmployeeID) -or
            [string]::IsNullOrWhiteSpace($employee.SamAccountName)) {
        $status = "REJECTED - Missing identity data"
    }
    
elseif ($duplicateEmployeeIDs -contains $employee.EmployeeID) {
    $status = "REJECTED - Duplicate employee ID"
}
elseif ($duplicateUsernames -contains $employee.SamAccountName) {
    $status = "REJECTED - Duplicate username"
}

    elseif (-not $departmentMap.ContainsKey($employee.Department)) {
        $status = "REJECTED - Unknown department"
    }
    else {
        $username = $employee.SamAccountName
        $expectedOU = $departmentMap[$employee.Department].OU
        $targetGroup = $departmentMap[$employee.Department].Group

        $adUser = Get-ADUser `
            -Filter "SamAccountName -eq '$username'" `
            -Properties EmployeeID, Department, Enabled `
            -ErrorAction Stop

        if (-not $adUser) {
            $status = "BLOCKED - AD account not found"
        }
        elseif ($adUser.EmployeeID -ne $employee.EmployeeID -or
                $adUser.Department -ne $employee.Department -or
                -not $adUser.DistinguishedName.EndsWith(",$expectedOU")) {
            $status = "BLOCKED - Identity attributes mismatch"
        }
        else {
            $group = Get-ADGroup -Identity $targetGroup -ErrorAction Stop

            $existingMembers = @(
                Get-ADGroupMember -Identity $group -ErrorAction Stop
            )

            if ($existingMembers.DistinguishedName -contains $adUser.DistinguishedName) {
                $status = "SKIPPED - Already a group member"
            }
            else {
                $status = "DRY RUN - Ready for group assignment"
            }
        }
    }

    [PSCustomObject]@{
        EmployeeID = $employee.EmployeeID
        Employee   = "$($employee.FirstName) $($employee.LastName)"
        Username   = $employee.SamAccountName
        Department = $employee.Department
        TargetGroup = $targetGroup
        Result     = $status
    }
}

Write-Host ""
Write-Host "RBAC GROUP ASSIGNMENT - DRY RUN" -ForegroundColor Cyan


# Preview group assignments without modifying Active Directory
Write-Host ""
Write-Host "RBAC GROUP ASSIGNMENT - WHATIF PREVIEW" -ForegroundColor Cyan


# Track actual RBAC execution outcomes separately from dry runs
$rbacExecutionResults = [System.Collections.Generic.List[object]]::new()

$eligibleAssignments = @(
    $results | Where-Object {
        $_.Result -eq "DRY RUN - Ready for group assignment"
    }
)


foreach ($assignment in $eligibleAssignments) {

    # Require exactly one matching HR request
    $requests = @(
        $employees | Where-Object {
            $_.SamAccountName -eq $assignment.Username
        }
    )

    if ($requests.Count -ne 1) {
        Write-Host "BLOCKED: $($assignment.Username) - Ambiguous HR request" -ForegroundColor Red
        continue
    }

    $request = $requests[0]

    # Revalidate approval and department mapping
    if ($request.ApprovalStatus -ne "Approved" -or
        $request.Action -ne "Joiner" -or
        -not $departmentMap.ContainsKey($request.Department)) {

        Write-Host "BLOCKED: $($assignment.Username) - Approval or department invalid" -ForegroundColor Red
        continue
    }

    $expectedOU = $departmentMap[$request.Department].OU
    $expectedGroup = $departmentMap[$request.Department].Group

    if ($assignment.TargetGroup -ne $expectedGroup -or
        $assignment.Department -ne $request.Department -or
        $assignment.EmployeeID -ne $request.EmployeeID) {

        Write-Host "BLOCKED: $($assignment.Username) - HR mapping mismatch" -ForegroundColor Red
        continue
    }

    # Recheck the current AD identity
    $adUser = Get-ADUser `
        -Identity $assignment.Username `
        -Properties EmployeeID, Department `
        -ErrorAction Stop

    if ($adUser.EmployeeID -ne $request.EmployeeID -or
        $adUser.Department -ne $request.Department -or
        -not $adUser.DistinguishedName.EndsWith(",$expectedOU")) {

        Write-Host "BLOCKED: $($assignment.Username) - AD identity mismatch" -ForegroundColor Red
        continue
    }

    
# Final membership check before any group assignment
$currentMembers = @(
    Get-ADGroupMember `
        -Identity $expectedGroup `
        -ErrorAction Stop
)

if ($currentMembers.DistinguishedName -contains $adUser.DistinguishedName) {
    Write-Host "SKIPPED: $($assignment.Username) - Already a member of $expectedGroup" -ForegroundColor Yellow
    continue
}

    Write-Host "VERIFIED: $($assignment.Username) -> $expectedGroup" -ForegroundColor Green

   
# Execute group assignment only when both controls are enabled
if ($EnableGroupAssignment -and $ConfirmGroupAssignment) {
    try {
        Add-ADGroupMember `
            -Identity $expectedGroup `
            -Members $adUser `
            -Confirm:$false `
            -ErrorAction Stop

        
# Verify membership directly in Active Directory after assignment
$verifiedMembers = @(
    Get-ADGroupMember `
        -Identity $expectedGroup `
        -ErrorAction Stop
)

if ($verifiedMembers.DistinguishedName -contains $adUser.DistinguishedName) {
    Write-Host "ASSIGNED AND VERIFIED: $($assignment.Username) -> $expectedGroup" -ForegroundColor Green

    
# Record verified RBAC assignment
$rbacExecutionResults.Add([PSCustomObject]@{
    Timestamp  = (Get-Date).ToString("o")
    EmployeeID = $request.EmployeeID
    Username   = $assignment.Username
    TargetGroup = $expectedGroup
    Status     = "ASSIGNED_AND_VERIFIED"
})

}
else {
    Write-Host "VERIFICATION FAILED: $($assignment.Username) -> $expectedGroup" -ForegroundColor Red

    
# Record group membership verification failure
$rbacExecutionResults.Add([PSCustomObject]@{
    Timestamp   = (Get-Date).ToString("o")
    EmployeeID  = $request.EmployeeID
    Username    = $assignment.Username
    TargetGroup = $expectedGroup
    Status      = "VERIFICATION_FAILED"
})

}

    }
    
catch {
    $errorMessage = $_.Exception.Message

    Write-Host "ASSIGNMENT ERROR: $($assignment.Username) - $errorMessage" -ForegroundColor Red

    $rbacExecutionResults.Add([PSCustomObject]@{
        Timestamp   = (Get-Date).ToString("o")
        EmployeeID  = $request.EmployeeID
        Username    = $assignment.Username
        TargetGroup = $expectedGroup
        Status      = "ASSIGNMENT_ERROR"
    })
}

}
else {
    # Preview without modifying Active Directory
    Add-ADGroupMember `
        -Identity $expectedGroup `
        -Members $adUser `
        -WhatIf `
        -ErrorAction Stop
}

}



# Display accurate preview or execution status
if ($EnableGroupAssignment -and $ConfirmGroupAssignment) {
    Write-Host "RBAC execution processed - Review verified assignment results." -ForegroundColor Yellow
}
else {
    Write-Host "WhatIf preview complete - No group memberships changed." -ForegroundColor Green
}


$results |
    Format-Table Employee, Username, Department, TargetGroup, Result -AutoSize

Write-Host ""

# Display completion message based on execution mode
if ($EnableGroupAssignment -and $ConfirmGroupAssignment) {
    Write-Host "RBAC EXECUTION COMPLETE - Review results and verify AD group memberships." -ForegroundColor Yellow
}
else {
    Write-Host "DRY RUN COMPLETE - No AD group memberships modified." -ForegroundColor Green
}



# Export RBAC validation results
$reportPath = "C:\IAM-Lab04\Reports\IAM-GroupAssignment-DryRun.csv"

$results |
    Export-Csv -Path $reportPath `
        -NoTypeInformation -Encoding UTF8

Write-Host "RBAC validation report exported: $reportPath" -ForegroundColor Cyan


# Export actual RBAC execution outcomes separately from dry-run results
$executionReportPath = "C:\IAM-Lab04\Reports\IAM-GroupAssignment-Execution.csv"

if ($rbacExecutionResults.Count -gt 0) {

    if (Test-Path $executionReportPath) {
        $rbacExecutionResults |
            Export-Csv -Path $executionReportPath `
                -Append -NoTypeInformation -Encoding UTF8
    }
    else {
        $rbacExecutionResults |
            Export-Csv -Path $executionReportPath `
                -NoTypeInformation -Encoding UTF8
    }

    Write-Host "RBAC execution report updated: $executionReportPath" -ForegroundColor Cyan
}
else {
    Write-Host "No RBAC assignments executed - execution report not generated." -ForegroundColor Yellow
}
