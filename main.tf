provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "lambda" {
  function_name    = "lbd-authorizer"
  role             = aws_iam_role.temp_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  filename         = "lambda.zip"
}

resource "aws_iam_role" "lambda" {
  name = "lambda-role"

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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}
