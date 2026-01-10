output "zone_id" {
  description = "ID de la hosted zone"
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "Name servers asignados por AWS"
  value       = aws_route53_zone.this.name_servers
}
