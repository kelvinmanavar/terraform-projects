# Terraform Day 8

## Overview

This directory contains the Terraform configuration for Day 8, demonstrating:
- S3 backend for remote state storage
- AWS provider configuration
- S3 bucket creation using `count` and `for_each`
- Explicit resource dependency with `depends_on`
- Resource lifecycle management
- Local tag merging and variable validation

## Prerequisites

1. Install Terraform 1.5.0 or later.
2. Configure AWS CLI credentials for the `default` profile.
3. Ensure the AWS region `ap-south-1` is available for your account.
4. Confirm the S3 backend bucket `terraform-state-bucket-22062026` exists and is accessible.

## Files

- `backend.tf` - configures the remote state backend using AWS S3.
- `provider.tf` - sets required providers and AWS provider configuration.
- `variable.tf` - defines environment variables, region, S3 bucket names, tags, and validation rules.
- `locals.tf` - defines reusable local tag values.
- `main.tf` - creates several S3 buckets and demonstrates advanced Terraform features.

## Step-by-Step Setup

### 1. Open the directory

```bash
cd /home/ubuntu/Documents/practiceWork/terraform-projects/day8
```

### 2. Review the backend configuration

The backend is configured in `backend.tf`:

- S3 bucket: `terraform-state-bucket-22062026`
- Key: `infrastructure/staging/terraform.tfstate`
- Region: `ap-south-1`
- Encryption enabled
- Locking enabled with `use_lockfile`

### 3. Initialize Terraform

```bash
terraform init
```

This command initializes the working directory, downloads providers, and configures the S3 backend.

### 4. Review the planned changes

```bash
terraform plan
```

The plan will show creation of several S3 buckets with tags and lifecycle settings.

### 5. Apply the infrastructure

```bash
terraform apply
```

Confirm the apply prompt to create the resources.

### 6. Destroy when finished

```bash
terraform destroy
```

Confirm the destroy prompt to remove the resources.

## Variable Overrides

You can customize the deployment by overriding variables with a `.tfvars` file or CLI flags.

Examples:

```hcl
# terraform.tfvars
environment = "dev"
region      = "ap-south-1"
```

Or with CLI:

```bash
terraform plan -var="environment=prod"
terraform apply -var="environment=prod"
```

## What This Configuration Creates

- `aws_s3_bucket.example_count` using `count` and `var.s3_bucket_names`
- `aws_s3_bucket.example_for_each` using `for_each` and `var.s3_bucket_Set`
- `aws_s3_bucket.primary` with a bucket name using `var.environment`
- `aws_s3_bucket.dependent` with `depends_on` ensuring creation after `primary`
- `aws_s3_bucket.lifecycle_Example` with lifecycle rules:
  - `create_before_destroy = true`
  - `ignore_changes` for `tags["CreatedDate"]`

## Notes

- `variable.tf` contains validation for `environment` and `instance_count` values.
- `locals.tf` merges `common_tags` with `var.resource_tags` to apply consistent tags.
- The configuration currently uses AWS profile `default` and the `ap-south-1` region.

## Troubleshooting

- If `terraform init` fails, verify AWS credentials and permissions for S3.
- If bucket names already exist, update `var.s3_bucket_names` or `var.s3_bucket_Set` to unique names.
- Ensure the state backend bucket exists before applying.
