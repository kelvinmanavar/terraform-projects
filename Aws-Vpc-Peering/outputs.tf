output "primary_vpc_id" {
	description = "ID of the primary VPC"
	value       = aws_vpc.primary_vpc.id
}

output "secondary_vpc_id" {
	description = "ID of the secondary VPC"
	value       = aws_vpc.secondary_vpc.id
}

output "primary_subnet_id" {
	description = "Primary subnet ID"
	value       = aws_subnet.primary_subnet.id
}

output "secondary_subnet_id" {
	description = "Secondary subnet ID"
	value       = aws_subnet.secondary_subnet.id
}

output "primary_instance_public_ip" {
	description = "Public IP of the primary EC2 instance"
	value       = aws_instance.primary_instance.public_ip
}

output "secondary_instance_public_ip" {
	description = "Public IP of the secondary EC2 instance"
	value       = aws_instance.secondary_instance.public_ip
}

output "primary_instance_private_ip" {
	description = "Private IP of the primary EC2 instance"
	value       = aws_instance.primary_instance.private_ip
}

output "secondary_instance_private_ip" {
	description = "Private IP of the secondary EC2 instance"
	value       = aws_instance.secondary_instance.private_ip
}

output "primary_sg_id" {
	description = "Security group ID for primary VPC"
	value       = aws_security_group.primary_sg.id
}

output "secondary_sg_id" {
	description = "Security group ID for secondary VPC"
	value       = aws_security_group.secondary_sg.id
}

output "vpc_peering_connection_id" {
	description = "VPC peering connection ID between primary and secondary"
	value       = aws_vpc_peering_connection.primary_to_secondary.id
}

output "primary_route_table_id" {
	description = "Primary VPC route table ID"
	value       = aws_route_table.primary_route_table.id
}

output "secondary_route_table_id" {
	description = "Secondary VPC route table ID"
	value       = aws_route_table.secondary_route_table.id
}

