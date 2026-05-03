resource "aws_iam_role" "role" {
  name = "most-opt-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "func" {
  filename      = "lambda_function.zip"
  function_name = "most-optimized-api"
  role          = aws_iam_role.role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
}