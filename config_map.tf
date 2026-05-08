resource "kubernetes_config_map_v1" "env_vars" {
  metadata {
    name      = "${local.app_name}-env-vars"
    namespace = kubernetes_namespace_v1.pihole.id
    labels = {
      app = local.app_name
    }
  }

  data = {
    FTLCONF_dns_upstreams          = local.gateway_ip
    FTLCONF_misc_etc_dnsmasq_d     = "true"
    FTLCONF_dns_reply_host_IPv4    = local.external_ip
    FTLCONF_dns_reply_host_force4  = "true"
    FTLCONF_webserver_port         = "80,443s"
    # FTLCONF_webserver_api_app_sudo = "true"
    FTLCONF_dns_listeningMode      = "ALL"
    VIRTUAL_HOST                   = "pi.hole"
    DNSSEC                         = "truei"
    TZ                             = "America/Chicago"
  }
}

resource "kubernetes_config_map_v1" "custom_dnsmasq" {
  metadata {
    name      = "${local.app_name}-custom-dnsmasq"
    namespace = kubernetes_namespace_v1.pihole.id
    labels = {
      app = local.app_name
    }
  }

  data = {
    "02-custom.conf" = <<-EOT
    addn-hosts=/etc/addn-hosts
    dhcp-option=6,${local.external_ip}
    EOT
  }
}