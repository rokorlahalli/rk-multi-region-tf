# AWS Multi-Region Infrastructure Assessment

This repository contains an **Infrastructure-as-Code solution using Terraform** that deploys a serverless architecture across two AWS regions:

* **us-east-1**
* **eu-west-1**

The stack includes:

* Amazon Cognito (authentication)
* API Gateway
* Lambda functions
* DynamoDB
* ECS Fargate
* SNS verification integration

The infrastructure is written in **modular Terraform** so the same stack is deployed identically in both regions.

---

# Repository Structure

```
.
├── modules/
│   ├── api-gateway/
│   ├── cognito/
│   ├── dynamodb/
│   ├── greeter_lambda/
│   ├── dispatcher_lambda/
│   └── ecs/
│
├── lambda_code/
│   ├── greeter_lambda/
│   └── dispatcher_lambda/
│
├── scripts/
│   └── test.py
│
├── main.tf
├── providers.tf
├── variables.tf
└── .github/workflows/deploy.yml
```

---

# Prerequisites

Install:

* Terraform (>=1.3)
* AWS CLI
* Python 3

Configure AWS credentials:

```
aws configure
```

The AWS user/role must have permissions to create:

* API Gateway
* Lambda
* DynamoDB
* ECS
* IAM
* Cognito
* SNS

---

# Deploy Infrastructure

Initialize Terraform:

```
terraform init
```

Review the deployment plan:

```
terraform plan
```

Apply the infrastructure:

```
terraform apply
```

Terraform will create all components in both regions.

---

# Create a Cognito Test User

Create a user in the Cognito user pool:

```
aws cognito-idp admin-create-user \
--region us-east-1 \
--user-pool-id <USER_POOL_ID> \
--username your_email@example.com \
--user-attributes Name=email,Value=your_email@example.com
```

Set a permanent password:

```
aws cognito-idp admin-set-user-password \
--region us-east-1 \
--user-pool-id <USER_POOL_ID> \
--username your_email@example.com \
--password YourPassword123! \
--permanent
```

---

# Run the Automated Test Script

Install dependencies:

```
pip install aiohttp
```

Run the test script:

```
python scripts/test.py
```

The script will:

1. Authenticate with Cognito to retrieve a JWT
2. Call `/greet` concurrently in **both regions**
3. Call `/dispatch` concurrently in **both regions**
4. Print responses and request latency
5. Validate that the returned region matches the expected region

---

# CI/CD Pipeline

A GitHub Actions workflow is included:

```
.github/workflows/deploy.yml
```

Pipeline stages:

1. Terraform formatting and validation
2. Security scanning using **tfsec**
3. Terraform plan generation
4. Terraform apply
5. Automated test execution

This demonstrates how the infrastructure would be deployed in a CI/CD pipeline.

---

# Cleanup

To remove all deployed infrastructure:

```
terraform destroy
```

---

# Contact

Email used for verification payload:

```
rohit.korlahalli21@gmail.com
```

Repository:

```
https://github.com/rokorlahalli/unleash-assessment
```
