resource "aws_security_group" "aurora_sg" {
  name        = "aurora-sg-${var.project}-${var.environment}"
  description = "Security Group for Aurora RDS Cluster"
  vpc_id      = aws_vpc.anaexames.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Aurora Security Group"
  }
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.1" 
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = 5
  preferred_backup_window = "00:00-02:00"
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.sg_group.name
  availability_zones      = ["sa-east-1a", "sa-east-1b"]  
  skip_final_snapshot     = true

  tags = {
    Name = "Aurora RDS Cluster"
  }
}

resource "aws_rds_cluster_instance" "writer" {
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = "db.r5.large"  
  engine             = "aurora-mysql"
  identifier         = "cluster-writer"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "Aurora Example Writer"
  }
}


resource "aws_rds_cluster_instance" "reader" {
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = "db.r5.large"
  engine             = "aurora-mysql"
  identifier         = "cluster-reader"


  availability_zone = "sa-east-1b"

  tags = {
    Name = "Aurora Example Reader"
  }
}

resource "aws_db_subnet_group" "sg_group" {
  name       = "aurora-private-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "Aurora Private Subnet Group"
  }
}
