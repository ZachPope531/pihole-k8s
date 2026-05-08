data "kubernetes_secret_v1" "web_password" {
  metadata {
    name      = "${local.app_name}-web-password"
    namespace = kubernetes_namespace_v1.pihole.id
  }
}