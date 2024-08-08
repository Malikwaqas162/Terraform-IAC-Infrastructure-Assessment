output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_a_id" {
  description = "The ID of the public subnet A"
  value       = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  description = "The ID of the public subnet B"
  value       = aws_subnet.public_b.id
}

output "private_subnet_a_id" {
  description = "The ID of the private subnet A"
  value       = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  description = "The ID of the private subnet B"
  value       = aws_subnet.private_b.id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT gateway"
  value       = aws_nat_gateway.nat.id
}

output "ssm_host_instance_id" {
  description = "The ID of the SSM host EC2 instance"
  value       = aws_instance.ssm_host.id
}

output "rds_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.master.endpoint
}

output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.master.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.sg.id
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "latest_amazon_linux_ami_id" {
  description = "The ID of the latest Amazon Linux 2 AMI"
  value       = data.aws_ami.latest_amazon_linux.id
}

output "master_instance_id" {
  value = aws_db_instance.master.id
}
