# WIF Status Check Script
Write-Host "WIF Status Check - Demo Ready" -ForegroundColor Cyan
Write-Host ""

# Check WIF Pool
Write-Host "Checking Workload Identity Pool..." -ForegroundColor Yellow
gcloud iam workload-identity-pools describe github-actions-pool --location=global --project=praxis-gear-483220-k4 --format="value(name)" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Pool Status: ACTIVE" -ForegroundColor Green
} else {
    Write-Host "  Pool Status: NOT FOUND" -ForegroundColor Red
}

Write-Host ""

# Check GitHub Provider
Write-Host "Checking GitHub Provider..." -ForegroundColor Yellow
gcloud iam workload-identity-pools providers describe github-actions --workload-identity-pool=github-actions-pool --location=global --project=praxis-gear-483220-k4 --format="value(name)" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Provider Status: ACTIVE" -ForegroundColor Green
} else {
    Write-Host "  Provider Status: NOT FOUND" -ForegroundColor Red
}

Write-Host ""

# Check Service Account
Write-Host "Checking Service Account..." -ForegroundColor Yellow
gcloud iam service-accounts describe github-actions-sa@praxis-gear-483220-k4.iam.gserviceaccount.com --project=praxis-gear-483220-k4 --format="value(email)" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Service Account Status: ACTIVE" -ForegroundColor Green
} else {
    Write-Host "  Service Account Status: NOT FOUND" -ForegroundColor Red
}

Write-Host ""
Write-Host "WIF Configuration Summary:" -ForegroundColor Cyan
Write-Host "  Pool: github-actions-pool" -ForegroundColor White
Write-Host "  Provider: github-actions" -ForegroundColor White
Write-Host "  Service Account: github-actions-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" -ForegroundColor White
Write-Host ""