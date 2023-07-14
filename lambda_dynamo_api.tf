
resource "aws_lambda_function" "my_lambda" {
  function_name    = "my-lambda-terraform-function"
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  filename         = "./index.zip"
  source_code_hash = filebase64sha256("./index.zip")
  role             = aws_iam_role.example_role.arn
}

resource "aws_dynamodb_table" "table_lambda2" {
  name           = "table-lambda2"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "N"
  }

  attribute {
    name = "job_type"
    type = "S"
  }

  attribute {
    name = "content"
    type = "S"
  }

  attribute {
    name = "processed"
    type = "S"
  }

  global_secondary_index {
    name               = "JobTypeIndex"
    hash_key           = "job_type"
    projection_type    = "ALL"
    read_capacity      = 5
    write_capacity     = 5
  }

  global_secondary_index {
    name               = "ContentIndex"
    hash_key           = "content"
    projection_type    = "ALL"
    read_capacity      = 5
    write_capacity     = 5
  }

  global_secondary_index {
    name               = "ProcessedIndex"
    hash_key           = "processed"
    projection_type    = "ALL"
    read_capacity      = 5
    write_capacity     = 5
  }
}


resource "aws_iam_policy" "dynamodb_policy" {
  name        = "db-policy-2"
  description = "Policy for DynamoDB table access"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Resource = aws_dynamodb_table.table_lambda2.arn
        Resource = aws_dynamodb_table.table_lambda2.arn

      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

resource "aws_iam_policy_attachment" "lambda_exec_policy_attachment" {
  name       = "lambda-exec-policy-attachment"
  roles      = [aws_iam_role.example_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_dynamo_policy_attachment" {
  name       = "lambda-dynamo-policy-attachment"
  roles      = [aws_iam_role.example_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role" "example_role" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_apigatewayv2_api" "api" {
  name          = "my-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  connection_type = "INTERNET"
  integration_uri    = aws_lambda_function.my_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /bonjour"
  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}
resource "aws_lambda_permission" "allow_lambda_invocation" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.my_lambda.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
  statement_id  = "AllowExecutionFromAPIGateway"
}
/*
resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_apigatewayv2_api.api.execution_arn
}
*/
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "prod"
  auto_deploy = true
}/*
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "dev2"
  auto_deploy = true
}*/
resource "aws_dynamodb_table" "job-content" {
  name           = "job-content"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "N"
  }

  attribute {
    name = "fetched_content"
    type = "S"
  }


  global_secondary_index {
    name               = "FetchedContentIndex"
    hash_key           = "fetched_content"
    projection_type    = "ALL"
    read_capacity      = 5
    write_capacity     = 5
  }

}


resource "aws_iam_policy" "dynamodb_policy-table-2" {
  name        = "dynamodb_policy-table-2"
  description = "Policy for DynamoDB table 2 access"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Resource = aws_dynamodb_table.job-content.arn
        Resource = aws_dynamodb_table.job-content.arn

      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment-2" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.dynamodb_policy-table-2.arn
  resources  = [aws_dynamodb_table.job-content.arn]

}