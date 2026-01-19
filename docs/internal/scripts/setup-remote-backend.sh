#!/bin/bash
# Setup Remote Backend for Production Environment
# This script creates a GCS bucket for storing Terraform state

set -e

PROJECT_ID="praxis-gear-483220-k4"
BUCKET_NAME="${PROJECT_ID}-terraform-state"
REGION="us-central1"

echo "🚀 Setting up Remote Backend for Production Environment"
echo "=================================================="

# Check if gcloud is authenticated
echo "📋 Checking Google Cloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ Not authenticated with Google Cloud. Please run:"
    echo "   gcloud auth login"
    echo "   gcloud auth application-default login"
    exit 1
fi

# Set the project
echo "🔧 Setting project to: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔌 Enabling required APIs..."
gcloud services enable storage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Create the bucket if it doesn't exist
echo "🪣 Creating GCS bucket: $BUCKET_NAME"
if gsutil ls -b gs://$BUCKET_NAME >/dev/null 2>&1; then
    echo "✅ Bucket already exists: gs://$BUCKET_NAME"
else
    gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$BUCKET_NAME
    echo "✅ Created bucket: gs://$BUCKET_NAME"
fi

# Enable versioning for state file backup
echo "🔄 Enabling versioning on bucket..."
gsutil versioning set on gs://$BUCKET_NAME

# Set lifecycle policy to manage old versions
echo "📋 Setting lifecycle policy..."
cat > lifecycle.json << EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "age": 30,
          "isLive": false
        }
      }
    ]
  }
}
EOF

gsutil lifecycle set lifecycle.json gs://$BUCKET_NAME
rm lifecycle.json

# Set appropriate permissions
echo "🔐 Setting bucket permissions..."
gsutil iam ch serviceAccount:$(gcloud config get-value account):objectAdmin gs://$BUCKET_NAME

echo ""
echo "✅ Remote Backend Setup Complete!"
echo "=================================================="
echo "📊 Backend Configuration:"
echo "   Bucket: gs://$BUCKET_NAME"
echo "   Region: $REGION"
echo "   Versioning: Enabled"
echo "   Lifecycle: 30 days for old versions"
echo ""
echo "🚀 Next Steps:"
echo "   1. cd environments/prod"
echo "   2. terraform init"
echo "   3. terraform plan"
echo "   4. terraform apply"
echo ""
echo "💡 State Comparison:"
echo "   Dev Environment:  Local state (terraform.tfstate.d/dev/)"
echo "   Prod Environment: Remote state (gs://$BUCKET_NAME/terraform/prod/)"