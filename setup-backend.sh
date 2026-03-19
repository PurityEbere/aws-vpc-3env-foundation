#!/bin/bash
set -e


# SETUP TERRAFORM REMOTE BACKEND
# ALL values come from .env.backend — nothing is hardcoded in this script
# .env.backend is gitignored and never pushed to GitHub


# Check secrets file exists
if [ ! -f ".env.backend" ]; then
    echo "❌ .env.backend file not found"
    echo ""
    echo "Create it by copying the example:"
    echo "  cp .env.backend.example .env.backend"
    echo "Then fill in your real values."
    exit 1
fi

# Load all values from .env.backend
source .env.backend

# Build full bucket name from parts (never hardcoded)
FULL_BUCKET_NAME="${BUCKET_NAME}-${AWS_ACCOUNT_ID}"

echo "========================================="
echo " Setting up Terraform Remote Backend"
echo "========================================="
echo ""

# Verify AWS credentials match the account in .env.backend
echo "Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured"
    echo "Run: aws configure"
    exit 1
fi

ACTUAL_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)

if [ "$ACTUAL_ACCOUNT" != "$AWS_ACCOUNT_ID" ]; then
    echo "❌ Account mismatch!"
    echo "   .env.backend says: $AWS_ACCOUNT_ID"
    echo "   AWS CLI is using:  $ACTUAL_ACCOUNT"
    echo "   Fix your aws configure or update .env.backend"
    exit 1
fi

echo "✅ AWS Account verified: $ACTUAL_ACCOUNT"
echo "✅ Bucket name: $FULL_BUCKET_NAME"
echo ""

# Create S3 bucket
echo "Creating S3 bucket..."
if aws s3api head-bucket --bucket "$FULL_BUCKET_NAME" 2>/dev/null; then
    echo "⚠️  Bucket already exists, skipping"
else
    aws s3api create-bucket \
        --bucket "$FULL_BUCKET_NAME" \
        --region "$AWS_REGION"
    echo "✅ S3 bucket created"
fi

# Enable versioning
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
    --bucket "$FULL_BUCKET_NAME" \
    --versioning-configuration Status=Enabled
echo "✅ Versioning enabled"

# Enable encryption
echo "Enabling encryption..."
aws s3api put-bucket-encryption \
    --bucket "$FULL_BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'
echo "✅ Encryption enabled"

# Block public access
echo "Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$FULL_BUCKET_NAME" \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
echo "✅ Public access blocked"

# Create DynamoDB table
echo "Creating DynamoDB table..."
if aws dynamodb describe-table \
    --table-name "$TABLE_NAME" \
    --region "$AWS_REGION" &>/dev/null; then
    echo "⚠️  Table already exists, skipping"
else
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$AWS_REGION" > /dev/null

    echo "Waiting for table to be active..."
    aws dynamodb wait table-exists \
        --table-name "$TABLE_NAME" \
        --region "$AWS_REGION"
    echo "✅ DynamoDB table created"
fi

# Generate backend.hcl files for each environment
echo ""
echo "Generating backend config files..."
for ENV in dev test prod; do
    mkdir -p environments/$ENV
    cat > environments/$ENV/backend.hcl << HCLEOF
bucket       = "${FULL_BUCKET_NAME}"
key          = "${ENV}/terraform.tfstate"
region       = "${AWS_REGION}"
use_lockfile = true
encrypt      = true
HCLEOF
    echo "✅ environments/$ENV/backend.hcl created"
done

# Generate terraform.tfvars files for each environment
echo ""
echo "Generating terraform.tfvars files..."

cat > environments/dev/terraform.tfvars << VARSEOF
environment        = "dev"
aws_region         = "${AWS_REGION}"
vpc_cidr           = "${DEV_VPC_CIDR}"
availability_zones = ["${AZ_1}", "${AZ_2}"]
VARSEOF
echo "✅ environments/dev/terraform.tfvars created"

cat > environments/test/terraform.tfvars << VARSEOF
environment        = "test"
aws_region         = "${AWS_REGION}"
vpc_cidr           = "${TEST_VPC_CIDR}"
availability_zones = ["${AZ_1}", "${AZ_2}"]
VARSEOF
echo "✅ environments/test/terraform.tfvars created"

cat > environments/prod/terraform.tfvars << VARSEOF
environment        = "prod"
aws_region         = "${AWS_REGION}"
vpc_cidr           = "${PROD_VPC_CIDR}"
availability_zones = ["${AZ_1}", "${AZ_2}"]
VARSEOF
echo "✅ environments/prod/terraform.tfvars created"

# Safety check — confirm nothing sensitive is tracked by git
echo ""
echo "Running safety check..."
SAFE=true
SENSITIVE_FILES=(
    ".env.backend"
    "environments/dev/backend.hcl"
    "environments/test/backend.hcl"
    "environments/prod/backend.hcl"
    "environments/dev/terraform.tfvars"
    "environments/test/terraform.tfvars"
    "environments/prod/terraform.tfvars"
)

for FILE in "${SENSITIVE_FILES[@]}"; do
    if git check-ignore -q "$FILE" 2>/dev/null; then
        echo "✅ $FILE is gitignored"
    else
        echo "❌ WARNING: $FILE is NOT gitignored"
        SAFE=false
    fi
done

if [ "$SAFE" = false ]; then
    echo ""
    echo "❌ Fix your .gitignore before pushing to GitHub"
    exit 1
fi

echo ""
echo "========================================="
echo "✅ Backend infrastructure ready!"
echo "========================================="
echo ""
echo "Deploy dev:   terraform init -reconfigure -backend-config=environments/dev/backend.hcl"
echo "Deploy test:  terraform init -reconfigure -backend-config=environments/test/backend.hcl"
echo "Deploy prod:  terraform init -reconfigure -backend-config=environments/prod/backend.hcl"
echo ""
