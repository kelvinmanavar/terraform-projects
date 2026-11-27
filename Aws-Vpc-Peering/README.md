# AWS Cross-Region VPC Peering Demo

Terraform configuration that connects two VPCs in different AWS regions with a VPC peering connection and launches one Ubuntu EC2 instance in each VPC to test connectivity.

| | Primary | Secondary |
|---|---|---|
| Region | `ap-south-1` (Mumbai) | `us-east-1` (N. Virginia) |
| VPC CIDR | `10.0.0.0/16` | `10.1.0.0/16` |
| Subnet CIDR | `10.0.1.0/24` | `10.1.1.0/24` |

## Architecture

```
 ap-south-1                                us-east-1
┌──────────────────────┐   peering   ┌──────────────────────┐
│ VPC 10.0.0.0/16      │◄───────────►│ VPC 10.1.0.0/16      │
│  └ Subnet 10.0.1.0/24│ (requester) │  └ Subnet 10.1.1.0/24│
│     └ EC2 (Apache)   │             │     └ EC2 (Apache)   │
│  IGW + route table   │             │  IGW + route table   │
└──────────────────────┘             └──────────────────────┘
```

## What gets created

In each region:

- VPC with DNS support and DNS hostnames enabled
- One public subnet (auto-assigns public IPs)
- Internet gateway, and a route table with a default route (`0.0.0.0/0`) to it
- Security group
- One Ubuntu 24.04 EC2 instance (`t2.micro` by default) running Apache

Between the regions:

- A peering connection requested from the primary VPC and accepted by the secondary VPC
- A static route in each route table that sends the other VPC's CIDR through the peering connection

## Prerequisites

- Terraform **1.10 or later**. The S3 backend uses `use_lockfile`, which was added in 1.10.
- AWS credentials for the `default` CLI profile, with permission to manage VPC, EC2 and S3 in both regions.
- An EC2 key pair in each region. The defaults are named `vpc-peering-demo` in both regions. To use different names, set `primary_key_name` and `secondary_key_name`.
- An existing S3 bucket named `terraform-state-bucket-22062026` in `ap-south-1` for remote state. Terraform does not create it. To use another bucket or a local state, edit `backend.tf`.

## Files

| File | Purpose |
|---|---|
| `backend.tf` | S3 remote state with encryption and lockfile locking |
| `provider.tf` | Terraform and provider versions, plus one AWS provider per region (`aws.primary`, `aws.secondary`) |
| `variable.tf` | Input variables |
| `data.tf` | Availability zones and latest Canonical Ubuntu 24.04 AMI for each region |
| `locals.tf` | EC2 user data scripts that install Apache and write a landing page |
| `main.tf` | VPCs, subnets, gateways, routes, security groups, instances, peering |
| `outputs.tf` | IDs and IP addresses of the created resources |

## Usage

Run these from the `Aws-Vpc-Peering` directory.

```bash
terraform init
terraform plan
terraform apply
```

Remove everything when finished:

```bash
terraform destroy
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `primary` | `ap-south-1` | Primary region name, used in tags, the peering request and the landing page |
| `secondary` | `us-east-1` | Secondary region name, used the same way |
| `primary_vpc_cidr` | `10.0.0.0/16` | Primary VPC CIDR |
| `secondary_vpc_cidr` | `10.1.0.0/16` | Secondary VPC CIDR. Must not overlap the primary CIDR |
| `primary_subnet_cidr` | `10.0.1.0/24` | Primary subnet CIDR |
| `secondary_subnet_cidr` | `10.1.1.0/24` | Secondary subnet CIDR |
| `instance_type` | `t2.micro` | EC2 instance type for both instances |
| `primary_key_name` | `vpc-peering-demo` | Key pair name in the primary region |
| `secondary_key_name` | `vpc-peering-demo` | Key pair name in the secondary region |
| `environment` | `staging` | Validated (`dev`, `staging`, `prod`) but not currently used by any resource |

Override defaults in a `terraform.tfvars` file (git-ignored) or with `-var` flags:

```hcl
secondary_key_name = "vpc-peering-demo-east"
instance_type      = "t3.micro"
```

> **Changing regions:** the regions are set in two places. `provider.tf` has them hardcoded, and the `primary`/`secondary` variables feed tags and the peering request. To use other regions, change both.

## Outputs

| Output | Description |
|---|---|
| `primary_vpc_id`, `secondary_vpc_id` | VPC IDs |
| `primary_subnet_id`, `secondary_subnet_id` | Subnet IDs |
| `primary_instance_public_ip`, `secondary_instance_public_ip` | Public IPs, for SSH |
| `primary_instance_private_ip`, `secondary_instance_private_ip` | Private IPs, for testing over the peering connection |
| `primary_sg_id`, `secondary_sg_id` | Security group IDs |
| `primary_route_table_id`, `secondary_route_table_id` | Route table IDs |
| `vpc_peering_connection_id` | Peering connection ID |

## Verify the peering

1. Get the IPs: `terraform output`.
2. SSH to the primary instance:
   ```bash
   ssh -i vpc-peering-demo.pem ubuntu@<primary_instance_public_ip>
   ```
3. From there, test the secondary instance by its **private** IP:
   ```bash
   ping <secondary_instance_private_ip>
   curl http://<secondary_instance_private_ip>
   ```
4. Repeat in the other direction. For the secondary instance, use the key file that matches `secondary_key_name`.

Both commands should succeed. If they time out, check that the peering connection status is `active` and that the route tables contain the peer CIDR.

## Security groups

| Direction | Source / destination | Allowed |
|---|---|---|
| Inbound | `0.0.0.0/0` | SSH (TCP 22) |
| Inbound | Peer VPC CIDR | ICMP |
| Inbound | Peer VPC CIDR | All TCP ports (0-65535) |
| Outbound | `0.0.0.0/0` | All traffic |

SSH is open to the whole internet, which is acceptable for a short-lived demo only. Restrict it to your own IP before using this elsewhere.

## Notes

- **Cost:** the instances and their public IPv4 addresses are billed while they exist. Cross-region data transfer is also billed. Run `terraform destroy` when you are done.
- **Key files:** `*.pem` files are listed in `.gitignore`. Never commit private keys.
- **Provider versions:** AWS provider `~> 6.0`. `provider.tf` also declares the `random` provider, but no resource uses it.
- **Apache page:** each instance serves a page at port 80 showing its region and IP, which makes the `curl` test above readable.
