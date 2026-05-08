resource "kubernetes_deployment_v1" "pihole" {
  metadata {
    name      = local.app_name
    namespace = kubernetes_namespace_v1.pihole.id
    labels = {
      app = local.app_name
    }
  }

  spec {
    replicas = 1 
    selector {
      match_labels = {
        app = local.app_name
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        generate_name = local.app_name
        labels = {
          app = local.app_name
        }
      }

      spec {
        topology_spread_constraint {
          topology_key = "kubernetes.io/hostname"
          label_selector {
            match_labels = {
              app = local.app_name
            }
          }
        }

        container {
          image = "pihole/pihole:latest"
          name  = local.app_name

          image_pull_policy = "Always"

          port {
            name           = "${local.port_names.dns}-tcp"
            container_port = 53
            host_port      = 53
            protocol       = "TCP"
          }
          port {
            name           = "${local.port_names.dns}-udp"
            container_port = 53
            host_port      = 53
            protocol       = "UDP"
          }
          port {
            name           = local.port_names.http
            container_port = 80
            protocol       = "TCP"
          }
          port {
            name           = local.port_names.https
            container_port = 443
            protocol       = "TCP"
          }

          readiness_probe {
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 5
            failure_threshold     = 10
            http_get {
              path   = "/admin"
              port   = local.port_names.http
              scheme = "HTTP"
            }
          }
          liveness_probe {
            initial_delay_seconds = 60
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 5
            failure_threshold     = 10
            http_get {
              path   = "/admin"
              port   = local.port_names.http
              scheme = "HTTP"
            }
          }

          security_context {
            capabilities {
              add = ["SYS_NICE"]
            }
          }

          env_from {
            config_map_ref {
              name     = kubernetes_config_map_v1.env_vars.metadata[0].name
              optional = false
            }
          }
          env {
            name = "FTLCONF_webserver_api_password"
            value_from {
              secret_key_ref {
                name = data.kubernetes_secret_v1.web_password.metadata[0].name
                key  = "password"
              }
            }
          }
          volume_mount {
            name       = kubernetes_config_map_v1.custom_dnsmasq.metadata[0].name
            sub_path   = "02-custom.conf"
            mount_path = "/etc/dnsmasq.d/02-custom.conf"
          }
          volume_mount {
            name       = local.app_name
            mount_path = "/etc/pihole"
          }
        }

        volume {
          name = local.app_name
          empty_dir {
            size_limit = "500Mi"
          }
        }

        volume {
          name = kubernetes_config_map_v1.custom_dnsmasq.metadata[0].name
          config_map {
            name = kubernetes_config_map_v1.custom_dnsmasq.metadata[0].name
          }
        }

        dns_config {
          nameservers = [
            "127.0.0.1",
            local.gateway_ip
          ]
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [spec[0].template[0].metadata[0].annotations["kubectl.kubernetes.io/restartedAt"]]
  }
}
