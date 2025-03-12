output "function_name" {
  value = aws_lambda_function.function.function_name
}

output "function_arn" {
  value = aws_lambda_function.function.arn
}

output "kms_key_arn" {
  value = aws_lambda_function.function.kms_key_arn
}