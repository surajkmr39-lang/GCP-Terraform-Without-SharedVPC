# Setup Remote Backend for Production Environment
# This script creates a GCS bucket for storing Terraform state

param(
    [string]$ProjectId = "praxis-gear-483220-k4",
    [string]$Region = "us-central1"
)

$BucketName = "$ProjectId-terraform-state"

Write-Host "Setting up Remote Backend for Production Environment" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Set the project
Write-Host "Setting project to: $ProjectId" -ForegroundColor Yellow
gcloud config set project $ProjectId

# Enable required APIs
Write-Host "Enabling required APIs..." -ForegroundColor Yellow
gcloud services enable storage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Create the bucket
Write-Host "Creating GCS bucket: $BucketName" -ForegroundColor Yellow
gsutil mb -p $ProjectId -c STANDARD -l $Region "gs://$BucketName" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Created bucket: gs://$BucketName" -ForegroundColor Green
} else {
    Write-Host "Bucket already exists: gs://$BucketName" -ForegroundColor Green
}

# Enable versioning for state file backup
Write-Host "Enabling versioning on bucket..." -ForegroundColor Yellow
gsutil versioning set on "gs://$BucketName"

Write-Host ""
Write-Host "Remote Backend Setup Complete!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host "Backend Configuration:" -ForegroundColor Cyan
Write-Host "   Bucket: gs://$BucketName" -ForegroundColor White
Write-Host "   Region: $Region" -ForegroundColor White
Write-Host "   Versioning: Enabled" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "   1. cd environments/prod" -ForegroundColor White
Write-Host "   2. terraform init" -ForegroundColor White
Write-Host "   3. terraform plan" -ForegroundColor White
Write-Host "   4. terraform apply" -ForegroundColor White
Write-Host ""
Write-Host "State Management Comparison:" -ForegroundColor Cyan
Write-Host "   Dev Environment:  Local state (terraform.tfstate.d/dev/)" -ForegroundColor Yellow
Write-Host "   Prod Environment: Remote state (gs://$BucketName/terraform/prod/)" -ForegroundColor Yellow