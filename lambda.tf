provider "aws" {
  region = "us-east-1"
}

resource "null_resource" "lambda_build" {
   triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "cd app && npm i && npm run build && cd dist && zip -r lambda_function_payload.zip . && ls"
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
  filename         = "${path.module}/app/dist/lambda_function_payload.zip"
  timeout          = var.lambda_timeout

  environment {
    variables = {
      "PUBLIC_KEY" = "aEwg7CU-pgDFKNZet7vFYPPhr_8gVrSn5M9rmfkNiM4"
    }
  }

  depends_on = [
    null_resource.lambda_build
  ]
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
