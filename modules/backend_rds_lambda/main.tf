
resource "aws_security_group" "db" {
  name        = "auto-guard-db-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20 # Free tier limit
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro" # Free tier eligible
  db_name                = "autoguard"
  username               = var.rds_username
  password               = var.rds_password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

resource "aws_db_subnet_group" "default" {
  name       = "auto-guard-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "lambda" {
  name        = "auto-guard-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "auto-guard-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "db_reader" {
  filename      = "${path.module}/lambda_function_payload.zip"
  function_name = "auto-guard-db-reader"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  memory_size   = 128 # Free tier optimization
  timeout       = 3   # Seconds

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      DB_HOST     = aws_db_instance.default.address
      DB_USER     = var.rds_username
      DB_PASSWORD = var.rds_password
      DB_NAME     = "autoguard"
    }
  }
}


# In backend_rds_lambda/main.tf
# In backend_rds_lambda/main.tf
resource "aws_iam_role_policy" "lambda_rds_access" {
  name = "lambda-rds-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "rds-db:connect"
      ],
      Effect   = "Allow",
      Resource = aws_db_instance.default.arn
    }]
  })
}