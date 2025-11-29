module "sg-bc-norte" {
  source = "git::https://github.com/stivasquez09/Terraform_Modules_AWS.git//SG?ref=v1.0.0"

  name          = local.name_sg
  vpc_id        = local.vpc_id
  description   = local.description
  ingress_rules = local.sg_ingress_rules
}


