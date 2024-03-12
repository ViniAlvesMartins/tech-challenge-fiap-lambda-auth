provider "aws" {
  region = "us-east-1"
}

data "archive_file" "main" {
  type        = "zip"
  source_file  = "${path.module}/tech-challenge-fiap-lambda-auth/app/dist/index.js"
  output_path = "${path.module}/tech-challenge-fiap-lambda-auth/archive_files/function.zip"

  depends_on = [null_resource.main]
}

resource "null_resource" "main" {

  triggers = {
    updated_at = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
    yarn
    EOF

    working_dir = "${path.module}/tech-challenge-fiap-lambda-auth/app/src"
  }
}

resource "aws_lambda_function" "lambda" {
  function_name    = "lbd-authorizer"
  role             = aws_iam_role.lambda.arn
  vpc_config {
    subnet_ids = var.lambda_subnet_ids
    security_group_ids = var.lambda_security_group_ids
  }
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  filename         = "${path.module}/tech-challenge-fiap-lambda-auth/archive_files/function.zip"
  timeout          = var.lambda_timeout
  source_code_hash = data.archive_file.main.output_base64sha256
  environment {
    variables = {
      "PUBLIC_KEY" = "aEwg7CU-pgDFKNZet7vFYPPhr_8gVrSn5M9rmfkNiM4"
    }
  }
}

resource "aws_iam_role" "lambda" {
  name = "lambda-authorizer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda" {
    role       = aws_iam_role.lambda.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:590183718917:2k35c7thu4/*"
}
