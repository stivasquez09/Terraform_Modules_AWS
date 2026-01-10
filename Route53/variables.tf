variable "domain_name" {
  description = "Nombre del dominio (example.com)"
  type        = string
}

variable "comment" {
  description = "Comentario para la hosted zone"
  type        = string
  default     = "Managed by Terraform"
}

variable "force_destroy" {
  description = "Permite eliminar la hosted zone aunque tenga registros"
  type        = bool
  default     = false
}

variable "records" {
  description = "Lista de registros DNS"
  type = list(object({
    name    = string
    type    = string
    ttl     = optional(number)
    records = optional(list(string))

    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool)
    }))
  }))
  default = []
}

variable "tags" {
  description = "Tags base obligatorias (enterprise)"
  type        = map(string)
}

variable "optional_tags" {
  description = "Tags opcionales (no obligatorios)"
  type        = map(string)
  default     = {}
}
variable "zone_type" {
  description = "Tipo de hosted zone: public | private"
  type        = string
  default     = "public"
  validation {
    condition     = contains(["public", "private"], var.zone_type)
    error_message = "zone_type debe ser public o private"
  }
}

variable "vpc_ids" {
  description = "Lista de VPC IDs para private hosted zone"
  type        = list(string)
  default     = []
}
