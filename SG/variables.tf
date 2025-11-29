variable "name" {
  description = "Nombre del Security Group"
  type        = string
}

variable "description" {
  description = "Descripción del Security Group"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC donde se creará el SG"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

variable "ingress_rules" {
  description = "Mapa de reglas ingress"
  type = map(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    security_groups  = optional(list(string))
    self             = optional(bool)
    description      = optional(string)
  }))
  default = {}
}

variable "egress_rules" {
  description = "Mapa de reglas egress"
  type = map(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    security_groups  = optional(list(string))
    self             = optional(bool)
    description      = optional(string)
  }))
  default = {}
}
