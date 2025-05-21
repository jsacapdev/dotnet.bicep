param (
    [string]$Entity,
    [string]$Environment
)

# Validate parameters
if (-not $Entity -or $Entity.Trim() -eq "") {
    throw "Parameter 'Entity' is required and cannot be empty."
}

if (-not $Environment -or $Environment.Trim() -eq "") {
    throw "Parameter 'Environment' is required and cannot be empty."
}

# Define result path
$resultsPath = "/workspace/scripts/testresults/$Entity-$Environment-ps-rule-results.xml"

# Run PSRule validation
Assert-PSRule -InputPath "/workspace/$Entity/" `
              -Option "/workspace/ps-rule.yaml" `
              -OutputPath $resultsPath `
              -OutputFormat NUnit3 `
              -Outcome Fail

# Parse NUnit v2.5 results
[xml]$nunit = Get-Content $resultsPath

$total = [int]$nunit.'test-results'.total
$failed = [int]$nunit.'test-results'.failures

Write-Host "Total tests: $total"
Write-Host "Failed tests: $failed"

if ($total -eq 0) {
    Write-Error "PSRule validation failed. The referenced module has errors."
    exit 1
}

if ($failed -gt 0) {
    Write-Error "PSRule validation failed: $failed tests failed."
    exit 1
}

# Proceed with deployment
az deployment sub create `
--name "workload-01.main-$(Get-Date -Format 'yyyyMMdd')-$(Get-Date -Format 'HHmmss')" `
--location westeurope `
-f "/workspace/$Entity/bicep/main.bicep" `
-p "/workspace/$Entity/bicep/env/$Environment.bicepparam"
