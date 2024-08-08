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
  Project     = "maybank-assessment-2024"
  Environment = "Sandbox_dev"
}
