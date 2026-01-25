# ECS Fider Deployment

Production deployment of Fider feedback platform on AWS using Docker, Terraform, and CI/CD.

**Live Application:** https://project-hub.click

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
- 2 Public subnets for ALB and ECS tasks
- 2 Private subnets for RDS database
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

bash
git clone 
https://github.com/EidAbokor1/ECS-FIDER-APP.git: https://github.com/EidAbokor1/ECS-FIDER-APP.git

cd ECS-FIDER-APP/terraform

### 2. Configure Variables

bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

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

### ECS Service Healthy
![ECS](./screenshots/ecs-healthy.png)

### Target Group Healthy
![Targets](./screenshots/targets-healthy.png)

### Successful CI/CD Pipeline
![Pipeline](./screenshots/pipeline-success.png)

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

```
Create workspaces
terraform workspace new dev
terraform workspace new production
Deploy to dev
terraform workspace select dev
terraform apply -var-file="terraform.dev.tfvars"
Deploy to production
terraform workspace select production
terraform apply -var-file="terraform.prod.tfvars"
```
Each workspace maintains separate state and infrastructure.

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
- ECS Fargate: ~$15
- RDS PostgreSQL: ~$15
- Application Load Balancer: ~$16
- NAT Gateway: ~$32
- Route 53: $0.50
- Data Transfer: ~$5
- **Total: ~$83/month**

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