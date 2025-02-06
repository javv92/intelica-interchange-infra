output "security_group_id" {
  value = aws_security_group.security_group.id
}

output "function_name" {
  value = aws_lambda_function.function.function_name
}