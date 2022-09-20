data "cloudflare_zone" "zone" {
  name = var.zone_name
}

resource "cloudflare_record" "vault" {
  zone_id = data.cloudflare_zone.zone.zone_id
  name    = var.domain_name
  type    = "CNAME"
  value   = aws_lb.vault.dns_name
  proxied = false
}
