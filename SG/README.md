# Security Group Module

Módulo reutilizable para crear Security Groups en AWS con Terraform.

## Uso

```hcl
module "sg_app" {
  source = "git::https://github.com/tu_usuario/terraform-modules.git//modules/security-group?ref=v1.0.0"

  name        = "app-sg"
  vpc_id      = "vpc-123456"
  description = "Security Group para app"

  ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
