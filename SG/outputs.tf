output "security_group_id" {
  value = aws_security_group.this.id
}

output "security_group_arn" {
  description = "ARN del Security Group."
  value       = aws_security_group.this.arn
}

output "security_group_name" {
  description = "Nombre del Security Group."
  value       = aws_security_group.this.name
}