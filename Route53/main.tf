
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
  for_each = { for r in var.records : r.name => r }

  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type

  ttl     = lookup(each.value, "ttl", null)
  records = lookup(each.value, "records", null)

  dynamic "alias" {
    for_each = lookup(each.value, "alias", null) == null ? [] : [each.value.alias]
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", false)
    }
  }
}
