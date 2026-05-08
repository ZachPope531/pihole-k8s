resource "kubernetes_namespace_v1" "pihole" {
  metadata {
    name = local.app_name
    labels = {
      app = local.app_name
    }
  }
}