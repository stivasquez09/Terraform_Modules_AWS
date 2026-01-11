resource "aws_route53_zone" "this" {
  name          = var.domain_name
  comment       = var.comment
  force_destroy = var.force_destroy

  # PRIVATE hosted zone → asociar VPCs
  dynamic "vpc" {
    for_each = var.zone_type == "private" ? var.vpc_ids : []
    content {
      vpc_id = vpc.value
    }
  }

  tags = merge(var.tags, var.optional_tags)
}

resource "aws_route53_record" "records" {
  for_each = { for r in var.records : "${r.name}_${r.type}" => r }

  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type

  # ✅ TTL y records como atributos simples (NO dynamic)
  # Solo se usan si NO hay alias
  ttl     = lookup(each.value, "alias", null) == null ? lookup(each.value, "ttl", 300) : null
  records = lookup(each.value, "alias", null) == null ? lookup(each.value, "records", []) : null

  # ✅ Alias como bloque dinámico (correcto)
  dynamic "alias" {
    for_each = lookup(each.value, "alias", null) != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", false)
    }
  }
}