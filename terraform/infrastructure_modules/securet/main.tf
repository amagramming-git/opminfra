module "secret" {
  source = "../../resource_modules/security/secret"

  name = var.name
}