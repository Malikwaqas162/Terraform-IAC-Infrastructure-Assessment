data "aws_db_instance" "master" {
  db_instance_identifier = aws_db_instance.master.id
}

resource "aws_db_instance" "replica" {
  engine               = "mariadb"
  engine_version       = "10.4.29"
  instance_class       = var.db_instance_class
  parameter_group_name = "default.mariadb10.4"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  replicate_source_db  = data.aws_db_instance.master.id
  availability_zone    = "us-west-2b"  # Ensure this is a different AZ from the master
  tags = merge(var.common_tags, { Name = "YOURORG-rds-replica" })
}
