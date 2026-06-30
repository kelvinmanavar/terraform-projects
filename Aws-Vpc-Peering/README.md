# AWS VPC Peering Demo

## Overview

This Terraform configuration creates a VPC peering connection between two AWS regions:

- Primary region: `ap-south-1`
- Secondary region: `us-east-1`

The module provisions:
- Two VPCs with CIDR blocks and DNS support enabled
- One subnet in each VPC
- Internet gateways and route tables
- Security groups for the EC2 instances
- Two Ubuntu EC2 instances
- A VPC peering connection with route propagation between the two networks

## Prerequisites

1. Install Terraform 1.5.0 or later.
2. Configure AWS CLI credentials for the `default` profile.
3. Ensure the target AWS regions are available in your account.
4. Create or import the EC2 key pairs named `vpc-peering-demo` in both regions, or override the key variables.
5. Make sure the S3 backend bucket `terraform-state-bucket-22062026` exists if you plan to use the remote state configuration.

## File Structure

- `backend.tf` – configures the remote S3 backend for Terraform state.
- `provider.tf` – defines the AWS providers for the primary and secondary regions.
- `variable.tf` – contains input variables for CIDRs, regions, instance type, and key pair names.
- `data.tf` – fetches availability zones and Ubuntu AMIs for both regions.
- `locals.tf` – defines user data scripts for the EC2 instances.
- `main.tf` – creates the VPCs, subnets, gateways, routes, security groups, instances, and peering resources.
- `outputs.tf` – exposes the created resource IDs and public/private IPs.

## Usage

### 1. Change into the module directory

```bash
cd /home/ubuntu/terraform-projects/Aws-Vpc-Peering
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the planned changes

```bash
terraform plan
```

### 4. Apply the configuration

```bash
terraform apply
```

### 5. Destroy the infrastructure when finished

```bash
terraform destroy
```

## Important Variables

You can override defaults with a `.tfvars` file or CLI flags.

Example:

```hcl
# terraform.tfvars
primary_vpc_cidr      = "10.0.0.0/16"
secondary_vpc_cidr    = "10.1.0.0/16"
primary_subnet_cidr   = "10.0.1.0/24"
secondary_subnet_cidr = "10.1.1.0/24"
instance_type         = "t2.micro"
```

## Outputs

After apply, Terraform will return values such as:
- Primary and secondary VPC IDs
- Primary and secondary subnet IDs
- Public and private IPs of the EC2 instances
- Security group IDs
- VPC peering connection ID

## Notes

- The configuration uses the AWS profile `default`.
- The EC2 instances are configured with user data to install Apache and serve a simple web page.
- The security groups allow SSH and ICMP traffic from the peer VPC CIDR.
