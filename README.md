# Assesment Infrastructure Deployment using Terraform

This repository contains Terraform configurations for deploying a multi-tier architecture on AWS. The setup includes VPC, subnets, internet gateway, NAT gateway, security groups, EC2 instances, RDS, S3, CloudFront, and a Network Load Balancer (NLB).

## Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Variables](#variables)
- [Outputs](#outputs)
- [Contributing](#contributing)
- [License](#license)

## Architecture

The architecture includes:

1. **VPC:** A Virtual Private Cloud with public and private subnets across two availability zones.
2. **Subnets:** 
   - Public Subnet A in AZ-1
   - Public Subnet B in AZ-2
   - Private Subnet A in AZ-1
   - Private Subnet B in AZ-2
3. **Internet Gateway:** For internet access in public subnets.
4. **NAT Gateway:** To allow private subnets to access the internet.
5. **Security Groups:** To control inbound and outbound traffic.
6. **EC2 Instances:** 
   - SSM Host in Public Subnet B
   - Application instances in a private subnet managed by an Auto Scaling Group (ASG).
7. **RDS:** 
   - MariaDB master in Private Subnet A
   - MariaDB replica in Private Subnet B.
8. **S3:** For object storage.
9. **CloudFront:** For content delivery.
10. **Network Load Balancer (NLB):** For distributing traffic to application instances.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v0.12+
- AWS account with appropriate permissions
- AWS CLI configured with your credentials

## Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/yourusername/maybank-infra-terraform.git
    cd maybank-infra-terraform
    ```

2. Install the necessary Terraform providers and modules:

    ```bash
    terraform init
    ```

## Usage

1. Update the `my_variable.tfvars` file with your configuration values.

    ```hcl
    region               = "us-west-2"
    vpc_cidr             = "192.168.0.0/16"
    public_subnet_cidr_a = "192.168.1.0/24"
    public_subnet_cidr_b = "192.168.2.0/24"
    private_subnet_cidr_a = "192.168.3.0/24"
    private_subnet_cidr_b = "192.168.4.0/24"
    instance_type        = "t2.micro"
    db_instance_class    = "db.t3.micro"
    db_user              = "admin"
    db_password          = "yourpassword"
    bucket_name          = "your-s3bucketname"

    common_tags = {
      Project     = "Maybank-Assessment-2024"
      Environment = "Sandbox_dev"
    }
    ```

2. Apply the Terraform configurations:

    ```bash
    terraform apply -var-file="my_variables.tfvars"
    ```

    Confirm the apply action with `yes`.

## Variables

Here are the main variables used in the configuration:

- `region`: The AWS region to create resources in.
- `vpc_cidr`: CIDR block for the VPC.
- `public_subnet_cidr_a`: CIDR block for the public subnet A.
- `public_subnet_cidr_b`: CIDR block for the public subnet B.
- `private_subnet_cidr_a`: CIDR block for the private subnet A.
- `private_subnet_cidr_b`: CIDR block for the private subnet B.
- `instance_type`: EC2 instance type.
- `db_instance_class`: RDS instance class.
- `db_user`: Database username.
- `db_password`: Database password.
- `bucket_name`: S3 bucket name.
- `common_tags`: Common tags for all resources (e.g., Project, Environment).

## Outputs

Here are the outputs provided by the configuration:

- `vpc_id`: The ID of the VPC.
- `public_subnet_a_id`: The ID of the public subnet A.
- `public_subnet_b_id`: The ID of the public subnet B.
- `private_subnet_a_id`: The ID of the private subnet A.
- `private_subnet_b_id`: The ID of the private subnet B.
- `internet_gateway_id`: The ID of the internet gateway.
- `nat_gateway_id`: The ID of the NAT gateway.
- `ssm_host_instance_id`: The ID of the SSM host EC2 instance.
- `rds_instance_endpoint`: The endpoint of the RDS instance.
- `rds_instance_id`: The ID of the RDS instance.
- `security_group_id`: The ID of the security group.
- `db_subnet_group_name`: The name of the DB subnet group.
- `latest_amazon_linux_ami_id`: The ID of the latest Amazon Linux 2 AMI.
- `master_instance_id`: The ID of the master RDS instance.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
