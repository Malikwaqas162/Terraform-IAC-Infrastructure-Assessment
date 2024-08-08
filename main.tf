terraform {
  backend "local" {}
}

provider "aws" {
  region = var.region
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.common_tags, { Name = "maybank-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.common_tags, { Name = "maybank-igw" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.common_tags, { Name = "maybank-public-rt" })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.common_tags, { Name = "maybank-private-rt" })
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_a
  availability_zone = "us-west-2a"
  tags = merge(var.common_tags, { 
    Name = "maybank-public-subnet-a",
    Availability_Zone = "AZ-1"
  })
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_b
  availability_zone = "us-west-2b"
  tags = merge(var.common_tags, { 
    Name = "maybank-public-subnet-b",
    Availability_Zone = "AZ-2"
  })
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_a
  availability_zone = "us-west-2a"
  tags = merge(var.common_tags, { 
    Name = "maybank-private-subnet-a",
    Availability_Zone = "AZ-1"
  })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_b
  availability_zone = "us-west-2b"
  tags = merge(var.common_tags, { 
    Name = "maybank-private-subnet-b",
    Availability_Zone = "AZ-2"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(var.common_tags, { Name = "maybank-nat-eip" })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
  tags          = merge(var.common_tags, { Name = "maybank-nat-gw" })
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "maybank-sg" })
}

resource "aws_launch_template" "app" {
  name_prefix   = "maybank-app-template-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, { Name = "maybank-app-instance" })
  }

  tag_specifications {
    resource_type = "volume"
    tags = var.common_tags
  }
}

resource "aws_autoscaling_group" "app" {
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  vpc_zone_identifier = [aws_subnet.private_a.id]

  min_size                = 1
  max_size                = 3
  desired_capacity        = 1
  health_check_type       = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "maybank-app-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.common_tags.Project
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.common_tags.Environment
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "maybank-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "maybank-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_instance" "ssm_host" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  tags                   = merge(var.common_tags, { Name = "maybank-ssm-host" })
}

resource "aws_db_instance" "master" {
  allocated_storage      = 20
  engine                 = "mariadb"
  engine_version         = "10.4.29"
  instance_class         = var.db_instance_class
  username               = var.db_user
  password               = var.db_password
  parameter_group_name   = "default.mariadb10.4"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  backup_retention_period = 7  # Enable automated backups for 7 days
  tags = merge(var.common_tags, { Name = "maybank-rds-master" })
}

resource "aws_db_subnet_group" "main" {
  name       = "maybank-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags       = merge(var.common_tags, { Name = "maybank-db-subnet-group" })
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}-${random_id.bucket_id.hex}"

  tags = merge(var.common_tags, { Name = "maybank-s3-bucket" })
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = "s3-my-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Maybank CloudFront Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "s3-my-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(var.common_tags, { Name = "maybank-cloudfront" })
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for my S3 bucket"
}

resource "aws_lb" "nlb" {
  name               = "maybank-public-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_a.id]

  tags = merge(var.common_tags, { Name = "maybank-public-nlb" })
}

resource "aws_lb_target_group" "target_group" {
  name     = "maybank-app-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = merge(var.common_tags, { Name = "maybank-target-group" })
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "maybank-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid = ""
      }
    ]
  })

  tags = merge(var.common_tags, { Name = "maybank-ssm-role" })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "maybank-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}
