# RDS Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids
}

# Security Group
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Or restrict to Lambda SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier             = "mydb"
  engine                 = "mysql"
  instance_class         = var.rds_instance_class
  allocated_storage      = 20
  username               = var.rds_username
  password               = var.rds_password
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_rds_s3_exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# IAM Policies for RDS and S3 and SQS
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_custom_policy" {
  name = "lambda-rds-s3-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["rds:*"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      },
      {
        Effect   = "Allow",
        Action   = ["sqs:SendMessage"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_custom_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_custom_policy.arn
}

# Archive Lambda Function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_code"
  output_path = "${path.module}/lambda_function_payload.zip"
}

resource "aws_lambda_function" "rds_exporter" {
  function_name = "rds-to-s3-exporter"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = data.archive_file.lambda_zip.output_path
  timeout       = 60
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.rds_sg.id]
  }
}

# Optional S3 VPC Endpoint (if no NAT gateway)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [data.aws_vpc.main.default_route_table_id] # Adjust accordingly
}

data "aws_region" "current" {}
data "aws_vpc" "main" {
  id = var.vpc_id
}
