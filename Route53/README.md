
# 🌐 AWS Route 53 Enterprise Module  

Módulo Terraform **enterprise & reutilizable** para administrar recursos de **Amazon Route 53**, permitiendo la creación confiable y estandarizada de zonas privadas, zonas públicas y registros DNS gestionados bajo buenas prácticas corporativas.

---

## 🚀 Características del Módulo  

- ✔️ Compatible con **zonas públicas y privadas**
- ✔️ Permite múltiples **registros DNS A, CNAME, AAAA, TXT, MX, SRV**
- ✔️ Soporta **alias hacia Load Balancer, CloudFront, API Gateway, S3 Website**
- ✔️ Estructura empresarial con etiquetas estándar
- ✔️ Validaciones para evitar errores comunes
- ✔️ Reutilizable para distintos entornos (**dev / qa / uat / prod**)

---

## 📦 Uso del Módulo  

### ✅ Ejemplo 1 — Zona Pública con Registros Web  

```hcl
module "route53_public_zone" {
  source = "./modules/route53"

  zone_name   = "mycompany.com"
  zone_type   = "public"

  records = [
    {
      name    = "app"
      type    = "A"
      ttl     = 300
      records = ["10.10.10.5"]
    },
    {
      name    = "www"
      type    = "CNAME"
      ttl     = 300
      records = ["app.mycompany.com"]
    }
  ]

  tags = {
    Project     = "Enterprise-Platform"
    Environment = "prod"
    Owner       = "CloudTeam"
  }
}
```

---

### ✅ Ejemplo 2 — Zona Privada Asociada a VPC  

```hcl
module "route53" {
  source      = "./modules/route53"
  domain_name = "internal.example.local"
  zone_type   = "private"

  vpc_ids = [
    "vpc-1234567890abcdef",
    "vpc-abcdef1234567890"
  ]

  tags = {
    Project = "platform"
    Env     = "prod"
  }

  records = [
    # -----------------------------
    # A record normal
    # -----------------------------
    {
      name    = "app.internal.example.local"
      type    = "A"
      ttl     = 300
      records = ["10.10.1.25"]
    },

    # -----------------------------
    # Alias (por ejemplo hacia ALB, NLB o CloudFront)
    # -----------------------------
    {
      name = "service.internal.example.local"
      type = "A"
      alias = {
        name                   = module.alb.dns_name
        zone_id                = module.alb.zone_id
        evaluate_target_health = true
      }
    },

    # -----------------------------
    # CNAME
    # -----------------------------
    {
      name    = "db.internal.example.local"
      type    = "CNAME"
      ttl     = 300
      records = ["database.internal.example.local"]
    },

    # -----------------------------
    # TXT (útil para validaciones internas)
    # -----------------------------
    {
      name    = "_verify.internal.example.local"
      type    = "TXT"
      ttl     = 300
      records = ["\"internal-validation\""]
    }
  ]
}

```
### ✅ Ejemplo Multidomain— Zona Privada Asociada a VPC  O zona publica  
### Archivo xxxx.tf
```hcl
# ============================================
# Route53 Hosted Zones - Multi-domain
# ============================================
module "route53" {
  source = "git::https://github.com/stivasquez09/Terraform_Modules_AWS.git//Route53?ref=v1.0.1"
  
  for_each = local.hosted_zones

  domain_name   = each.value.domain_name
  zone_type     = each.value.zone_type
  comment       = lookup(each.value, "comment", "Managed by Terraform")
  force_destroy = lookup(each.value, "force_destroy", false)
  vpc_ids       = lookup(each.value, "vpc_ids", [])
  records       = lookup(each.value, "records", [])
  tags          = each.value.tags
  optional_tags = lookup(each.value, "optional_tags", {})
}

```
### Archivo local.tf
```hcl
locals {
  # VPC IDs para zonas privadas
  vpc_main_id = aws_vpc.main1.id
  vpc_dev_id  = "vpc-0a1b2c3d"  # Si tienes otra VPC

  hosted_zones = {
    
    # ==================== ZONA PRIVADA: INTERNAL ====================
    internal = {
      domain_name = "internal.example.local"
      zone_type   = "private"
      comment     = "Internal private DNS zone"
      vpc_ids     = [local.vpc_main_id]
      
      tags = {
        Project     = "platform"
        Environment = "production"
        Type        = "private"
      }
      
      records = [
        # A record
        {
          name    = "app.internal.example.local"
          type    = "A"
          ttl     = 300
          records = ["10.10.1.25"]
        },
        # Database CNAME
        {
          name    = "db.internal.example.local"
          type    = "CNAME"
          ttl     = 300
          records = ["rds-postgres.internal.example.local"]
        },
        # Redis
        {
          name    = "redis.internal.example.local"
          type    = "A"
          ttl     = 300
          records = ["10.10.1.50"]
        }
      ]
    }

    # ==================== ZONA PRIVADA: SERVICES ====================
    services = {
      domain_name = "services.internal.local"
      zone_type   = "private"
      comment     = "Microservices internal DNS"
      vpc_ids     = [local.vpc_main_id]
      
      tags = {
        Project     = "microservices"
        Environment = "production"
        Type        = "private"
      }
      
      records = [
        # API Gateway
        {
          name    = "api.services.internal.local"
          type    = "A"
          ttl     = 300
          records = ["10.10.2.10"]
        },
        # Auth service
        {
          name    = "auth.services.internal.local"
          type    = "A"
          ttl     = 300
          records = ["10.10.2.20"]
        },
        # User service
        {
          name    = "users.services.internal.local"
          type    = "A"
          ttl     = 300
          records = ["10.10.2.30"]
        }
      ]
    }

    # ==================== ZONA PRIVADA: DEV ====================
    dev_internal = {
      domain_name = "dev.internal.local"
      zone_type   = "private"
      comment     = "Development environment DNS"
      vpc_ids     = [local.vpc_dev_id]
      
      tags = {
        Project     = "platform"
        Environment = "development"
        Type        = "private"
      }
      
      records = [
        {
          name    = "app-dev.dev.internal.local"
          type    = "A"
          ttl     = 300
          records = ["10.20.1.10"]
        },
        {
          name    = "db-dev.dev.internal.local"
          type    = "A"
          ttl     = 300
          records = ["10.20.1.20"]
        }
      ]
    }

    # ==================== ZONA PÚBLICA: EXAMPLE.COM ====================
    public_main = {
      domain_name = "example.com"
      zone_type   = "public"
      comment     = "Main public domain"
      
      tags = {
        Project     = "website"
        Environment = "production"
        Type        = "public"
      }
      
      records = [
        # Root domain - A record
        {
          name    = "example.com"
          type    = "A"
          ttl     = 300
          records = ["203.0.113.10"]
        },
        # WWW - CNAME
        {
          name    = "www.example.com"
          type    = "CNAME"
          ttl     = 300
          records = ["example.com"]
        },
        # API subdomain
        {
          name    = "api.example.com"
          type    = "A"
          ttl     = 300
          records = ["203.0.113.20"]
        },
        # Mail records
        {
          name    = "example.com"
          type    = "MX"
          ttl     = 300
          records = ["10 mail.example.com"]
        },
        # SPF
        {
          name    = "example.com"
          type    = "TXT"
          ttl     = 300
          records = ["\"v=spf1 include:_spf.google.com ~all\""]
        }
      ]
    }

    # ==================== ZONA PÚBLICA: APP.COM (con ALB Alias) ====================
    public_app = {
      domain_name = "app-example.com"
      zone_type   = "public"
      comment     = "Application public domain with ALB"
      
      tags = {
        Project     = "app"
        Environment = "production"
        Type        = "public"
      }
      
      records = [
        # Root con Alias a ALB
        {
          name = "app-example.com"
          type = "A"
          alias = {
            name                   = "my-alb-123456.us-east-1.elb.amazonaws.com"
            zone_id                = "Z35SXDOTRQ7X7K"  # ALB zone ID
            evaluate_target_health = true
          }
        },
        # WWW con Alias a ALB
        {
          name = "www.app-example.com"
          type = "A"
          alias = {
            name                   = "my-alb-123456.us-east-1.elb.amazonaws.com"
            zone_id                = "Z35SXDOTRQ7X7K"
            evaluate_target_health = true
          }
        },
        # API subdomain
        {
          name    = "api.app-example.com"
          type    = "A"
          ttl     = 300
          records = ["203.0.113.30"]
        }
      ]
    }

    # ==================== ZONA PÚBLICA: SUBDOMAIN ====================
    public_subdomain = {
      domain_name = "blog.example.com"
      zone_type   = "public"
      comment     = "Blog subdomain"
      
      tags = {
        Project     = "blog"
        Environment = "production"
        Type        = "public"
      }
      
      records = [
        {
          name    = "blog.example.com"
          type    = "A"
          ttl     = 300
          records = ["198.51.100.10"]
        },
        {
          name    = "www.blog.example.com"
          type    = "CNAME"
          ttl     = 300
          records = ["blog.example.com"]
        }
      ]
    }

  }
}

```

---

## ⚙️ Variables Principales  

| Variable | Tipo | Requerida | Descripción |
|--------|------|----------|-------------|
| zone_name | string | Sí | Nombre de la zona (ej: `mycompany.com`) |
| zone_type | string | Sí | `public` o `private` |
| vpc_ids | list(string) | Opcional | Requerido solo si la zona es privada |
| records | list(object) | Opcional | Lista de registros DNS |
| tags | map(string) | Opcional | Etiquetas estándar corporativas |

---

## 📤 Outputs  

| Output | Descripción |
|--------|-------------|
| zone_id | ID de la zona creada |
| zone_name | Nombre de la zona |
| name_servers | Servidores DNS asignados (solo zonas públicas) |

---

## 🛑 Reglas Importantes & Errores Comunes  

- ❌ No crear zonas públicas para dominios sin registrar
- ❌ No olvidar asociar VPCs en zonas privadas
- ❌ No duplicar registros con mismo nombre + tipo
- ❌ Evitar TTL extremadamente bajos en producción

---

## 🛡️ Buenas Prácticas Enterprise  

- 🌍 Usar **zonas privadas** para servicios internos
- 🏛️ Aplicar **principio de menor exposición**
- 🏷️ Mantener **etiquetas consistentes**
- 🔐 Evitar registros sensibles públicos
- 🧪 Manejar ambientes separados por zona o subdominio

---

## 👨‍💻 Uso Recomendado por Entorno  

| Entorno | Recomendación |
|--------|----------------|
| DEV | TTL bajos para pruebas |
| QA / UAT | Réplicas cercanas a PROD |
| PROD | TTL estable, cambios controlados |

---

## ✅ Estado Empresarial  
Este módulo está diseñado siguiendo estándares:

- Cloud Architecture Best Practices
- AWS Well-Architected Framework
- Reutilización – Escalabilidad – Observabilidad

---

## 🤝 Contribuciones  
Pull Requests bienvenidos. Mantén el mismo estilo estructurado y enfoque empresarial.

---

## 📄 Licencia  
Uso corporativo interno — ajustable según tu organización.

---

