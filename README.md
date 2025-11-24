# LocalStack Development Environment

A local AWS development environment using LocalStack, Docker, and Terraform. This setup allows you to develop and test AWS services (S3, SES) locally without connecting to real AWS infrastructure.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/)
- (Optional) [awslocal](https://github.com/localstack/awscli-local) - `pip install awscli-local`

## Project Structure

```
.
├── docker-compose.yml    # LocalStack container configuration
├── providers.tf          # Terraform AWS provider setup
├── variables.tf          # Configurable variables
├── main.tf              # S3 bucket resources
├── ses.tf               # SES email resources
├── outputs.tf           # Terraform outputs
├── .env                 # Environment variables (not committed)
└── volume/              # LocalStack persistent data (not committed)
```

## Quick Start

### 1. Start LocalStack

```bash
docker-compose up -d
```

Verify it's running:
```bash
docker-compose ps
```

### 2. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply configuration
terraform apply
```

### 3. Install awslocal

```bash
pip install awscli-local
```

The `awslocal` command is a wrapper around AWS CLI that automatically points to LocalStack (no profile configuration needed).

## Configuration

### Variables

Customize in `variables.tf` or override via command line:

```bash
terraform apply \
  -var="aws_region=us-east-1" \
  -var="bucket_name=my-custom-bucket" \
  -var="ses_sender_email=sender@domain.com"
```

### Environment Variables

Create a `.env` file:
```bash
AWS_PROFILE=localstack
DEBUG=0
```

## Usage Examples

### S3

**List buckets:**
```bash
awslocal s3 ls
```

**Create a bucket:**
```bash
awslocal s3 mb s3://test-bucket
```

**Upload a file:**
```bash
awslocal s3 cp file.txt s3://my-local-bucket/
```

**Download a file:**
```bash
awslocal s3 cp s3://my-local-bucket/file.txt downloaded.txt
```

**List objects in bucket:**
```bash
awslocal s3 ls s3://my-local-bucket/
```

**Delete a file:**
```bash
awslocal s3 rm s3://my-local-bucket/file.txt
```

**Delete a bucket:**
```bash
awslocal s3 rb s3://test-bucket --force
```

### SES

**List verified identities:**
```bash
awslocal ses list-identities
```

**Send a simple email:**
```bash
awslocal ses send-email \
  --from sender@example.com \
  --destination "ToAddresses=recipient@example.com" \
  --message "Subject={Data=Test Email},Body={Text={Data='Hello from LocalStack SES'}}"
```

**Send email with HTML:**
```bash
awslocal ses send-email \
  --from sender@example.com \
  --destination "ToAddresses=recipient@example.com" \
  --message "Subject={Data=HTML Email},Body={Html={Data='<h1>Hello</h1><p>This is a test.</p>'}}"
```

**Send templated email:**
```bash
awslocal ses send-templated-email \
  --source sender@example.com \
  --destination "ToAddresses=recipient@example.com" \
  --template example-template \
  --template-data '{"name":"John Doe"}'
```

**Verify a new email identity:**
```bash
awslocal ses verify-email-identity --email-address newuser@example.com
```

**Get send quota:**
```bash
awslocal ses get-send-quota
```

## LocalStack Features

| Feature | Endpoint | Status |
|---------|----------|--------|
| S3 | `http://localhost:4566` | ✓ Configured |
| SES | `http://localhost:4566` | ✓ Configured |
| Gateway | Port 4566 | Single endpoint for all services |
| Persistence | Enabled | Data saved to `./volume/` |
| Health Check | `http://localhost:4566/_localstack/health` | Auto-monitored |

## Useful Commands

### Docker

```bash
# Start LocalStack
docker-compose up -d

# View logs
docker-compose logs -f

# Stop LocalStack
docker-compose down

# Check health
docker inspect my-localstack-main --format='{{.State.Health.Status}}'
```

### Terraform

```bash
# Format code
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# Destroy all resources
terraform destroy
```

### awslocal

```bash
# Check LocalStack health
curl http://localhost:4566/_localstack/health

# List all S3 buckets
awslocal s3 ls

# List verified SES identities
awslocal ses list-identities

# Get SES send quota
awslocal ses get-send-quota
```

## Troubleshooting

### LocalStack not starting

Check if the port is already in use:
```bash
lsof -i :4566
```

View container logs:
```bash
docker-compose logs localstack
```

### Terraform connection issues

Verify LocalStack is running:
```bash
curl http://localhost:4566/_localstack/health
```

Check endpoint configuration in `providers.tf`.

### "No changes" after updating region

S3 buckets are global resources. To recreate:
```bash
terraform destroy
terraform apply
```

### awslocal not working

Make sure it's installed:
```bash
pip install awscli-local
```

Test with explicit endpoint:
```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

## Cleanup

```bash
# Stop and remove containers
docker-compose down

# Remove Terraform state
rm -rf .terraform terraform.tfstate*

# Remove persistent data
rm -rf volume/
```

## Additional Resources

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [LocalStack GitHub](https://github.com/localstack/localstack)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)

## License

This project is for local development purposes.
