resource "aws_lambda_function" "redutor_imagem" {
  timeout          = 120
  function_name    = "redutor-imagem"
  filename         = "${path.root}/../../microservices/tmp/redutor-imagem.zip"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  memory_size      = 512
  source_code_hash = filebase64sha256("${path.root}/../../microservices/tmp/redutor-imagem.zip")
  ephemeral_storage {
    size = 512
  }
  environment {
    variables = {
      S3_BUCKET_IMAGEM_ORIGINAL = aws_s3_bucket.imagem_original.bucket,
      S3_BUCKET_IMAGEM_REDUZIDA = aws_s3_bucket.imagem_reduzida.bucket,
    }
  }
  role = aws_iam_role.redutor_imagem.arn
  layers = [
    "arn:aws:lambda:us-east-1:553035198032:layer:git-lambda2:8"
  ]
}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.imagem_original.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.redutor_imagem.arn
    events              = ["s3:ObjectCreated:*"]

  }
  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redutor_imagem.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.imagem_original.arn
}

resource "aws_iam_role" "redutor_imagem" {
  name = "redutor-imagem-repo-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redutor_imagem_basic" {
  role       = aws_iam_role.redutor_imagem.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "redutor_imagem_permissions" {
  name = "redutor-imagem-repo-policy"
  role = aws_iam_role.redutor_imagem.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["s3:PutObject", "s3:GetObject"],
      Effect = "Allow",
      Resource = [
        aws_s3_bucket.imagem_original.arn,
        "${aws_s3_bucket.imagem_original.arn}/*"
      ]
    },
    {
      Action = ["s3:PutObject", "s3:GetObject"],
      Effect = "Allow",
      Resource = [
        aws_s3_bucket.imagem_reduzida.arn,
        "${aws_s3_bucket.imagem_reduzida.arn}/*"
      ]
    }
    ]
  })
}
