# 🔐 AWS Security Group Terraform Module

Módulo **reutilizable y empresarial** para la creación y gestión de **Security Groups en AWS** usando Terraform.  
Diseñado para soportar arquitecturas modernas, buenas prácticas de seguridad y estandarización en proyectos Cloud.

---

## 🚀 Características

✔️ Compatible con cualquier VPC  
✔️ Soporta reglas **ingress** y **egress** dinámicas  
✔️ Permite reglas con:
- CIDR Blocks
- Security Groups
- Self Rules
- Prefix Lists
- IPv4 & IPv6  
✔️ Estructura limpia y lista para entornos empresariales  
✔️ Incluye etiquetas para gobernanza y trazabilidad  

---

## 📦 Uso del Módulo

---

### ✅ Ejemplo 1 – Web Server (CIDR vs Security Group)

> **Nunca mezclar `cidr_blocks` con `source_security_group_id` en una misma regla**

```hcl
module "web_server_sg" {
  source = "./modules/security-group"

  name        = "web-server-sg"
  description = "Web server with mixed access"
  vpc_id      = var.vpc_id

  ingress_rules = [
    # ❌ NO COMBINAR
    # ✅ Solo CIDR
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS from Internet"
    },

    # ✅ Solo Security Group
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = "sg-bastion123456"
      description              = "SSH from bastion"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound"
    }
  ]

  tags = {
    Name        = "web-server-sg"
    Environment = "prod"
    Project     = "enterprise-app"
  }
}
```

---

### ✅ Ejemplo 2 – Database Server (SELF vs Security Group)

> **Nunca mezclar `self` con `source_security_group_id`**

```hcl
module "postgres_cluster_sg" {
  source = "./modules/security-group"

  name        = "postgres-cluster-sg"
  description = "PostgreSQL cluster"
  vpc_id      = var.vpc_id

  ingress_rules = [
    # ❌ NO COMBINAR

    # ✅ SELF – replicación del cluster
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      self        = true
      description = "Replication between cluster nodes"
    },

    # ✅ Security Group – acceso app
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = "sg-webapp-abc123"
      description              = "PostgreSQL from web app"
    }
  ]

  egress_rules = []

  tags = {
    Name = "postgres-cluster-sg"
  }
}
```

---

### ✅ Ejemplo 3 – Redis Cache (SELF vs CIDR)

> **Nunca mezclar `self` con `cidr_blocks`**

```hcl
module "redis_sg" {
  source = "./modules/security-group"

  name        = "redis-cache-sg"
  description = "Redis ElastiCache cluster"
  vpc_id      = var.vpc_id

  ingress_rules = [
    # ❌ NO COMBINAR

    # ✅ SELF – comunicación interna
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      self        = true
      description = "Redis cluster sync"
    },

    # ✅ CIDR – acceso desde VPC
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Redis from VPC"
    }
  ]

  egress_rules = []

  tags = {
    Name = "redis-cache-sg"
  }
}
```

---

### ✅ Ejemplo 4 – Kafka Cluster (Todos los casos)

```hcl
module "kafka_sg" {
  source = "./modules/security-group"

  name        = "kafka-cluster-sg"
  description = "Kafka message broker"
  vpc_id      = var.vpc_id

  ingress_rules = [
    # SELF - brokers
    {
      from_port   = 9092
      to_port     = 9092
      protocol    = "tcp"
      self        = true
      description = "Kafka inter-broker communication"
    },

    # CIDR - productores
    {
      from_port   = 9092
      to_port     = 9092
      protocol    = "tcp"
      cidr_blocks = ["10.0.10.0/24"]
      description = "Kafka producers from private subnet"
    },

    # SG - consumidores
    {
      from_port                = 9092
      to_port                  = 9092
      protocol                 = "tcp"
      source_security_group_id = "sg-app-consumers"
      description              = "Kafka consumers from app"
    },

    # SELF - Zookeeper
    {
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      self        = true
      description = "Zookeeper cluster communication"
    }
  ]

  egress_rules = [
    {
      from_port   = 9092
      to_port     = 9092
      protocol    = "tcp"
      self        = true
      description = "Kafka responses within cluster"
    }
  ]

  tags = {
    Name    = "kafka-cluster-sg"
    Service = "kafka"
  }
}
```

---

### ✅ Ejemplo 5 – Lambda + VPC Endpoints (Prefix List)

> **Nunca mezclar `prefix_list_id` con `cidr_blocks`**

```hcl
module "lambda_sg" {
  source = "./modules/security-group"

  name        = "lambda-function-sg"
  description = "Lambda with VPC endpoints"
  vpc_id      = var.vpc_id

  ingress_rules = []

  egress_rules = [
    # Prefix List – S3
    {
      from_port      = 443
      to_port        = 443
      protocol       = "tcp"
      prefix_list_id = ["pl-63a5400a"]
      description    = "S3 via VPC endpoint"
    },

    # Prefix List – DynamoDB
    {
      from_port      = 443
      to_port        = 443
      protocol       = "tcp"
      prefix_list_id = ["pl-02cd2c6b"]
      description    = "DynamoDB via VPC endpoint"
    },

    # CIDR – Internet
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS to Internet"
    },

    # SG – RDS
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = "sg-rds-database"
      description              = "PostgreSQL to RDS"
    }
  ]

  tags = {
    Name = "lambda-function-sg"
  }
}
```

---

### ✅ Ejemplo 6 – Elasticsearch (IPv4 vs IPv6)

```hcl
module "elasticsearch_sg" {
  source = "./modules/security-group"

  name        = "elasticsearch-sg"
  description = "Elasticsearch cluster"
  vpc_id      = var.vpc_id

  ingress_rules = [
    # SELF
    {
      from_port   = 9200
      to_port     = 9300
      protocol    = "tcp"
      self        = true
      description = "ES cluster communication"
    },

    # IPv4
    {
      from_port   = 9200
      to_port     = 9200
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "ES API from VPC IPv4"
    },

    # IPv6
    {
      from_port        = 9200
      to_port          = 9200
      protocol         = "tcp"
      ipv6_cidr_blocks = ["2001:db8::/32"]
      description      = "ES API from VPC IPv6"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      self        = true
      description = "All internal cluster traffic"
    }
  ]

  tags = {
    Name = "elasticsearch-sg"
  }
}
```

---

### ✅ Ejemplo Multi security_groups en ciclo para ambientes y un solo llamado desde un archivo locals
### arhivo XXX.tf

```hcl

# ============================================
# Security groups multi
# ============================================
module "security_group" {
  source      = "git::https://github.com/stivasquez09/Terraform_Modules_AWS.git//SG?ref=master"
  for_each = local.security_groups

  vpc_id        = lookup(local.security_groups, each.key, {})["vpc_id"]
  name          = lookup(local.security_groups, each.key, {})["name"]
  description   = lookup(local.security_groups, each.key, {})["description"]
  ingress_rules = lookup(local.security_groups, each.key, {})["ingress_rules"]
  egress_rules  = lookup(local.security_groups, each.key, {})["egress_rules"]
}
```
### arhivo local.tf
```hcl


locals {
  vpc_id = aws_vpc.main1.id

  security_groups = {
    # ==================== WEB SERVER SG ====================
    web_server = {
      vpc_id      = local.vpc_id
      name        = "prod-web-server-sg"
      description = "Security group for web servers"

      ingress_rules = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS from Internet"
        },
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP from Internet"
        },
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
          description = "SSH from VPC"
        }
      ]

      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]

      tags = {
        Name        = "prod-web-server-sg"
        Environment = "production"
      }
    }

    # ==================== APPLICATION SG ====================
    application = {
      vpc_id      = local.vpc_id
      name        = "prod-application-sg"
      description = "Security group for application tier"

      ingress_rules = [
        {
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          self        = true
          description = "Inter-app communication"
        }
      ]

      egress_rules = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS to Internet"
        }
      ]

      tags = {
        Name        = "prod-application-sg"
        Environment = "production"
      }
    }

    # ==================== DATABASE SG ====================
    database = {
      vpc_id      = local.vpc_id
      name        = "prod-database-sg"
      description = "Security group for RDS PostgreSQL"

      ingress_rules = [
        {
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
          self        = true
          description = "PostgreSQL replication"
        }
      ]

      egress_rules = []

      tags = {
        Name        = "prod-database-sg"
        Environment = "production"
      }
    }

    # ==================== ALB SG ====================
    alb = {
      vpc_id      = local.vpc_id
      name        = "prod-alb-sg"
      description = "Security group for Application Load Balancer"

      ingress_rules = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS from Internet"
        },
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP from Internet"
        }
      ]

      egress_rules = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS outbound"
        }
      ]

      tags = {
        Name        = "prod-alb-sg"
        Environment = "production" # ✅ Agregado
      }
    } # ✅ Llave correctamente cerrada

    # ==================== BASTION HOST SG ====================
    bastion = {
      vpc_id      = local.vpc_id
      name        = "prod-bastion-sg"
      description = "Security group for bastion host"

      ingress_rules = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["203.0.113.0/24"]
          description = "SSH from corporate"
        }
      ]

      egress_rules = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
          description = "SSH to VPC"
        }
      ]

      tags = {
        Name        = "prod-bastion-sg"
        Environment = "production"
      }
    }
  }
}

```
---

## ⚙️ Variables Principales

| Variable | Tipo | Requerida | Descripción |
|--------|------|----------|------------|
| `name` | string | ✔️ | Nombre del Security Group |
| `description` | string | ✔️ | Descripción del recurso |
| `vpc_id` | string | ✔️ | ID de la VPC |
| `ingress_rules` | list(object) | ❌ | Reglas de entrada |
| `egress_rules` | list(object) | ❌ | Reglas de salida |
| `tags` | map(string) | ❌ | Etiquetas |

---

## 🛡️ Recomendaciones y Buenas Prácticas

### ❌ Reglas de **NO COMBINACIÓN** en una misma regla
> Estas combinaciones NO deben usarse juntas en una misma regla. Si necesitas ambas, sepáralas en reglas distintas.

| ❌ No combinar | ✅ Forma correcta |
|--------------|------------------|
| `cidr_blocks` + `source_security_group_id` | Regla 1: CIDR • Regla 2: SG |
| `cidr_blocks` + `self` | Regla 1: CIDR • Regla 2: self |
| `source_security_group_id` + `self` | Regla 1: SG • Regla 2: self |
| `prefix_list_id` + `cidr_blocks` | Regla 1: prefix • Regla 2: CIDR |

> 🔎 **Nota importante:**  
> `ipv6_cidr_blocks` **sí puede combinarse** con `cidr_blocks` en la misma regla si necesitas permitir ambos.  
> Sin embargo, en entornos empresariales normalmente se separan para mantener claridad, auditoría y control.

---

### 🧠 Buenas Prácticas Generales
- 🔐 **No mezclar fuentes** en una misma regla
- 🌍 **Evitar `0.0.0.0/0`** para puertos sensibles
- 🏷️ **Usar etiquetas (tags)** para trazabilidad y gobierno
- 🏛️ Aplicar **principio de menor privilegio**

---

## 📤 Outputs Recomendados

| Output | Descripción |
|--------|------------|
| `security_group_id` | ID del Security Group |
| `security_group_arn` | ARN del Security Group |

---

## 🧩 Compatibilidad

- Terraform `>= 1.x`
- AWS Provider `>= 5.x`

---

## 👨‍💻 Mantenimiento

Repositorio diseñado para uso empresarial:
- Código limpio
- Estándar corporativo
- Multi-ambiente (dev, qa, uat, prod)

---

## 📚 Licencia
Uso libre siguiendo buenas prácticas de seguridad.
