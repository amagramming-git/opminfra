# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret
output "id" {
  value       = aws_secretsmanager_secret.this.id
}
output "arn" {
  value       = aws_secretsmanager_secret.this.arn
}
output "replica" {
  value       = aws_secretsmanager_secret.this.replica
}
output "tags_all" {
  value       = aws_secretsmanager_secret.this.tags_all
}