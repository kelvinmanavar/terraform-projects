variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "primary" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "secondary" {
  description = "Secondary AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "primary_vpc_cidr" {
  description = "CIDR block for the primary VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "secondary_vpc_cidr" {
  description = "CIDR block for the secondary VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "primary_subnet_cidr" {
  description = "CIDR block for the primary subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "secondary_subnet_cidr" {
  description = "CIDR block for the secondary subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "primary_key_name" {
  description = "Name of the SSH key pair for Primary VPC instance (ap-south-1)"
  type        = string
  default     = "vpc-peering-demo"
}

variable "secondary_key_name" {
  description = "Name of the SSH key pair for Secondary VPC instance (us-east-1)"
  type        = string
  default     = "vpc-peering-demo"
}