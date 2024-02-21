# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret
output "id" {
  value       = module.secret.id
}
output "arn" {
  value       = module.secret.arn
}
output "replica" {
  value       = module.secret.replica
}
output "tags_all" {
  value       = module.secret.tags_all
}