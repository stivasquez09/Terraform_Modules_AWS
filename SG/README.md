# Security Group Module

Módulo reutilizable para crear Security Groups en AWS con Terraform.

## Uso

```hcl


module "app_sg" {
  source = "git::https://github.com/stivasquez09/Terraform_Modules_AWS.git//SG?ref=v1.0.0"

  name        = "app-sg"
  description = "Security group for application"
  vpc_id      = "vpc-xxxxx"

  ingress_rules = [
    # Regla con CIDR
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS from Internet"
    },
    # Regla con source_security_group_id
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = "sg-xxxxxxxxx"
      description              = "MySQL from app layer"
    },
    # Otra regla con source_security_group_id
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = "sg-yyyyyyyyy"
      description              = "SSH from bastion"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}