resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  tags        = var.tags

  # Reglas INGRESS SOLO con CIDR (sin source_security_group_id)
  dynamic "ingress" {
    for_each = [
      for rule in var.ingress_rules : rule
      if lookup(rule, "source_security_group_id", null) == null # ✅ Filtro agregado
    ]
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(ingress.value, "prefix_list_id", null)
      self             = lookup(ingress.value, "self", null)
      description      = lookup(ingress.value, "description", null)
    }
  }

  # Reglas EGRESS SOLO con CIDR (sin source_security_group_id)
  dynamic "egress" {
    for_each = [
      for rule in var.egress_rules : rule
      if lookup(rule, "source_security_group_id", null) == null # ✅ Filtro agregado
    ]
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(egress.value, "prefix_list_id", null)
      self             = lookup(egress.value, "self", null)
      description      = lookup(egress.value, "description", null)
    }
  }
}

# ========== REGLAS SEPARADAS CON SOURCE_SECURITY_GROUP_ID ==========

# Reglas INGRESS con source_security_group_id
resource "aws_security_group_rule" "ingress_sg" {
  for_each = {
    for idx, rule in var.ingress_rules :
    "ingress-sg-${idx}" => rule
    if lookup(rule, "source_security_group_id", null) != null
  }

  type                     = "ingress"
  security_group_id        = aws_security_group.this.id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_security_group_id
  prefix_list_ids          = lookup(each.value, "prefix_list_id", null)
  description              = lookup(each.value, "description", null)
}

# Reglas EGRESS con source_security_group_id
resource "aws_security_group_rule" "egress_sg" {
  for_each = {
    for idx, rule in var.egress_rules :
    "egress-sg-${idx}" => rule
    if lookup(rule, "source_security_group_id", null) != null
  }

  type                     = "egress"
  security_group_id        = aws_security_group.this.id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_security_group_id
  prefix_list_ids          = lookup(each.value, "prefix_list_id", null)
  description              = lookup(each.value, "description", null)
}
