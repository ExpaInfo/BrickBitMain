module "site_production" {
  source = "./default_ecr"

  repository_name = "brickbit/site/production"
  cache           = true

  staging_account_id = var.staging_account_id
}

module "nginx" {
  source = "./default_ecr"

  repository_name = "brickbit/site/nginx"
  cache           = true

  staging_account_id = var.staging_account_id
}

module "fluentd" {
  source = "./default_ecr"

  repository_name = "brickbit/site/logging/fluentd"

  staging_account_id = var.staging_account_id
}

module "blog" {
  source = "./default_ecr"

  repository_name = "brickbit/site/blog/ghost"
  cache           = true

  staging_account_id = var.staging_account_id
}
