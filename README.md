# ECS Fider Deployment

Production deployment of Fider feedback platform on AWS using Docker, Terraform, and CI/CD.

**Live Application:** [https://project-hub.click](https://demo.fider.io/)


---

## Overview

This project deploys Fider (an open-source feedback management tool) on AWS with:

- **Containerization:** Docker multi-stage build
- **Infrastructure:** Terraform with modular architecture
- **Orchestration:** ECS Fargate (serverless containers)
- **Database:** RDS PostgreSQL with Multi-AZ
- **Load Balancing:** Application Load Balancer with HTTPS
- **CI/CD:** GitHub Actions with automated deployments
- **Security:** Private subnets, security groups, secrets management

---

## Architecture

![Architecture Diagram](./images/Screenshot%202026-01-24%20at%2017.35.19.png)

### Components

**Network:**
- VPC (10.0.0.0/16) across 2 availability zones
- 2 Public subnets for ALB
- 2 Private subnets for ECS tasks and RDS database
- Internet Gateway and NAT Gateway

**Compute:**
- ECS Fargate cluster with 2 tasks
- Docker image stored in ECR
- Auto-scaling capable

**Database:**
- RDS PostgreSQL 17.6
- Multi-AZ deployment
- Automated backups

**Security:**
- Security groups (ALB → ECS → RDS)
- IAM roles with least privilege
- Secrets Manager for sensitive data
- SSL/TLS encryption

**DNS & SSL:**
- Route 53 for DNS management
- ACM certificate for HTTPS
- Automatic certificate validation

---

## Repository Structure
```
├── fider/                  
├── Dockerfile              
├── docker-compose.yml      
├── .dockerignore
│
├── terraform/              
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── backend.tf
│   ├── oidc.tf
│   └── modules/
│       ├── networking/
│       ├── security/
│       ├── iam/
│       ├── database/
│       ├── load-balancer/
│       ├── dns/
│       ├── ses/
│       ├── secrets/
│       ├── ecs/
│       └── ecr/
│
├── .github/workflows/      
│   ├── docker-build-push.yml
│   ├── terraform-deploy.yml
│   └── health-check.yml
│
├── .gitignore
└── README.md
```
---

## Local Development

### Quick Start
```bash
git clone https://github.com/EidAbokor1/ECS-FIDER-APP.git
cd ECS-FIDER-APP

docker-compose up -d
```

### Local Services
- **Fider Application**: http://localhost:80
- **MailHog (Email Testing)**: http://localhost:8025
- **PostgreSQL Database**: localhost:5555

### Development Features
- Hot-reload for code changes
- Local PostgreSQL with persistent data
- Email testing with MailHog
- Debug logging enabled

---

## Database Management

### Schema & Migrations
- **70+ migration files** in `fider/migrations/`
- Automatic migration on container startup
- PostgreSQL 17 with full-text search
- Multi-language content support

### Migration Commands
```bash
docker exec -it fider_container ./fider migrate

docker-compose down -v
docker-compose up -d
```

---

## Internationalization

### Supported Languages
20+ languages including:
- English, Spanish, French, German
- Arabic, Chinese, Japanese, Korean
- Portuguese, Russian, Italian
- And more in `locale/` directory

### Adding New Languages
```bash
npm run locale:extract

cp locale/en/ locale/your-language/
```

---

## ECR Bootstrap

### Initial ECR Setup
```bash
chmod +x bootstrap-ecr.sh

./bootstrap-ecr.sh
```

This creates the ECR repository required before first Terraform deployment.

---

## Terraform State Management

### S3 Backend Configuration
- **S3 bucket**: `fider-terraform-state-123456789012`
- **Native locking**: Enabled with `use_lockfile = true`
- **Encryption**: Enabled for state files
- **No DynamoDB**: Uses S3 native locking instead

### State Locking Benefits
- Prevents concurrent deployments
- No additional DynamoDB costs
- Automatic lock cleanup
- Built into Terraform S3 backend

---

## Testing

### End-to-End Tests
Located in `e2e/` directory:
- **Framework**: Playwright/Cucumber
- **Features**: User scenarios in Gherkin
- **Setup**: Automated test environment

### Running Tests
```bash
cd fider
npm run test:e2e
```

---

## Prerequisites

- AWS Account
- Terraform >= 1.6.0
- Docker Desktop
- AWS CLI configured
- Domain name (Route 53 or external)
- GitHub account

---

## Setup Instructions

### 1. Clone Repository

```
git clone https://github.com/EidAbokor1/ECS-FIDER-APP.git

cd ECS-FIDER-APP/terraform
```
### 2. Configure Variables

```
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

Required values:
- `domain_name` - Your domain
- `db_password` - Database password
- `jwt_secret` - Generate with: `openssl rand -base64 48`
- `smtp_username` - SES SMTP username
- `smtp_password` - SES SMTP password
- `admin_email` - Your email

### 3. Configure AWS

```
aws configure
# Enter Access Key, Secret Key, Region (eu-west-2)
```
### 4. Deploy Infrastructure

```
terraform init
terraform plan
terraform apply
```
Deployment takes 15-20 minutes.

### 5. Update Nameservers (If Needed)

If domain is in different account:

```
terraform output route53_nameservers
# Copy the 4 nameservers and update in domain registrar
```

### 6. Verify Email

Check inbox for SES verification email and click the link.

### 7. Access Application

https://your-domain.com

---

## Screenshots

### Application Running
![App](./images/Screenshot%202026-01-25%20at%2015.50.21.png)

<video width="600" controls>
  <source src="./images/Screen%20Recording%202026-01-25%20at%2015.53.19.mp4" type="video/mp4">
</video>

https://github.com/user-attachments/assets/97d04a1f-021b-4d04-95af-66205b11b255



### ECS Service Healthy
![ECS](./images/Screenshot%202026-01-25%20at%2016.03.59.png)
![ECS](./images/Screenshot%202026-01-25%20at%2016.04.24.png)

### Target Group Healthy
![Targets](./images/Screenshot%202026-01-25%20at%2016.06.45.png)

### Successful CI/CD Pipeline
![Pipeline](./images/Screenshot%202026-01-25%20at%2016.16.02.png)
![Pipeline](./images/Screenshot%202026-01-25%20at%2016.16.42.png)
![Pipeline](./images/Screenshot%202026-01-25%20at%2016.18.09.png)

---

## CI/CD Pipelines

### Docker Build & Push
**Trigger:** Push to main (app code changes)

**Steps:**
1. Build Docker image (linux/amd64)
2. Tag with commit SHA
3. Push to ECR
4. Update ECS service

### Terraform Deploy
**Trigger:** Push to main (infrastructure changes) or manual

**Steps:**
1. Format check
2. Validate configuration
3. Plan changes
4. Apply changes

### Health Check
**Trigger:** After deployment completes

**Steps:**
1. Wait for tasks to stabilize
2. Test application endpoint
3. Retry up to 10 times
4. Fail if unhealthy

---

## Terraform Workspaces

Manage multiple environments with the same code:

### Create Workspaces
```bash
# Create development workspace
terraform workspace new dev

# Create production workspace  
terraform workspace new production

# List all workspaces
terraform workspace list
```

### Deploy to Development
```bash
# Switch to dev workspace
terraform workspace select dev

# Apply with dev-specific variables
terraform apply -var-file="terraform.dev.tfvars"
```

### Deploy to Production
```bash
# Switch to production workspace
terraform workspace select production

# Apply with production-specific variables
terraform apply -var-file="terraform.prod.tfvars"
```

### Workspace Benefits
- **Separate state files**: Each workspace maintains isolated state
- **Same codebase**: Use identical Terraform code for all environments
- **Resource isolation**: Resources are prefixed with workspace name
- **Environment-specific variables**: Different tfvars files per environment

### Important Notes
- Default workspace uses `var.environment` from tfvars
- Named workspaces use workspace name as environment identifier
- Each workspace creates completely separate infrastructure
- State files stored as `env:/workspace/terraform.tfstate` in S3

---

## Maintenance

### View Logs

```
aws logs tail /ecs/fider --follow --region eu-west-2
```
### Restart Application

``` 
aws ecs update-service \
  --cluster fider-cluster \
  --service fider-service \
  --force-new-deployment \
  --region eu-west-2`
```
### Update Application

Push changes to trigger automated deployment:
```
git add .
git commit -m "Update application"
git push origin main`
```
---

## Cleanup

```
cd terraform
terraform destroy
```
Confirm by typing `yes`. Takes 10-15 minutes.

---

## Cost Estimate

**Monthly costs:**
- ECS Fargate: $15
- RDS PostgreSQL: $15
- Application Load Balancer: $16
- NAT Gateway: $32
- Route 53: $0.50
- Data Transfer: $5
- **Total: $83/month**

---

## Troubleshooting

**Tasks not starting:**
- Check CloudWatch logs: `/ecs/fider`
- Verify secrets in Secrets Manager
- Check security group rules

**DNS not resolving:**
- Verify nameservers updated
- Wait 15-60 minutes for propagation
- Check Route 53 records

**Certificate not validating:**
- Check DNS records in Route 53
- Wait up to 30 minutes
- Verify domain ownership

**Targets unhealthy:**
- Check health check settings (accept 200, 307)
- Verify security groups allow ALB → ECS traffic
- Check application logs

---

## Technologies

- **Cloud:** AWS (ECS, RDS, ALB, Route 53, ACM, SES)
- **IaC:** Terraform (modular)
- **Containers:** Docker
- **CI/CD:** GitHub Actions
- **Auth:** AWS OIDC
- **Database:** PostgreSQL 17
- **Application:** Fider (Go + React)

---

## Author

Eid Abokor - [GitHub](https://github.com/EidAbokor1)

---

## License

Educational project. Fider is licensed under AGPL-3.0.
