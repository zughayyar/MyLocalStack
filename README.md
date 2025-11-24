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

### 3. Configure AWS CLI

**Option A: Using AWS Profile**

Add to `~/.aws/config`:
```ini
[profile localstack]
region = ca-central-1
endpoint_url = http://localhost:4566
```

Add to `~/.aws/credentials`:
```ini
[localstack]
aws_access_key_id = test
aws_secret_access_key = test
```

Then use:
```bash
export AWS_PROFILE=localstack
aws s3 ls
```

**Option B: Using awslocal**

```bash
pip install awscli-local
awslocal s3 ls
```

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

**Upload a file:**
```bash
aws --profile localstack s3 cp file.txt s3://my-local-bucket/
# or
awslocal s3 cp file.txt s3://my-local-bucket/
```

**List objects:**
```bash
aws --profile localstack s3 ls s3://my-local-bucket/
```

**Python (boto3):**
```python
import boto3

s3 = boto3.client(
    's3',
    endpoint_url='http://localhost:4566',
    aws_access_key_id='test',
    aws_secret_access_key='test',
    region_name='ca-central-1'
)

# Upload file
s3.upload_file('local.txt', 'my-local-bucket', 'remote.txt')

# List buckets
response = s3.list_buckets()
print(response['Buckets'])
```

**Node.js (AWS SDK v3):**
```javascript
import { S3Client, ListBucketsCommand } from '@aws-sdk/client-s3';

const s3 = new S3Client({
  endpoint: 'http://localhost:4566',
  region: 'ca-central-1',
  credentials: {
    accessKeyId: 'test',
    secretAccessKey: 'test',
  },
  forcePathStyle: true,
});

const response = await s3.send(new ListBucketsCommand({}));
console.log(response.Buckets);
```

### SES

**Send an email:**
```bash
aws --profile localstack ses send-email \
  --from sender@example.com \
  --destination "ToAddresses=recipient@example.com" \
  --message "Subject={Data=Test},Body={Text={Data='Hello from LocalStack'}}"
```

**Python (boto3):**
```python
import boto3

ses = boto3.client(
    'ses',
    endpoint_url='http://localhost:4566',
    region_name='ca-central-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

response = ses.send_email(
    Source='sender@example.com',
    Destination={'ToAddresses': ['recipient@example.com']},
    Message={
        'Subject': {'Data': 'Test Email'},
        'Body': {'Text': {'Data': 'Hello from LocalStack!'}}
    }
)
print(f"Message ID: {response['MessageId']}")
```

**Using Template:**
```python
response = ses.send_templated_email(
    Source='sender@example.com',
    Destination={'ToAddresses': ['recipient@example.com']},
    Template='example-template',
    TemplateData='{"name": "John Doe"}'
)
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

### AWS CLI

```bash
# Check LocalStack health
curl http://localhost:4566/_localstack/health

# List all S3 buckets
aws --profile localstack s3 ls

# List verified SES identities
aws --profile localstack ses list-identities

# Get SES send quota
aws --profile localstack ses get-send-quota
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

### AWS CLI not connecting

Verify your profile configuration:
```bash
aws configure list --profile localstack
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
