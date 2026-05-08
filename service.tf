resource "kubernetes_service_v1" "web" {
  metadata {
    name      = "${local.app_name}-svc-web"
    namespace = kubernetes_namespace_v1.pihole.id
    labels = {
      app = local.app_name
    }
    annotations = {
      "metallb.io/allow-shared-ip" = "${local.app_name}-svc"
      "metallb.io/address-pool"    = kubernetes_manifest.metallb_pihole_pool.manifest.metadata.name
    }
  }

  spec {
    type             = "LoadBalancer"
    load_balancer_ip = local.external_ip

    port {
      name        = local.port_names.http
      port        = 80
      target_port = local.port_names.http
    }
    port {
      name        = local.port_names.https
      port        = 443
      target_port = local.port_names.https
    }

    selector = {
      app = local.app_name
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations["metallb.io/ip-allocated-from-pool"]]
  }
}

resource "kubernetes_service_v1" "dns" {
  for_each = toset(["TCP", "UDP"])
  metadata {
    name      = "${local.app_name}-svc-${lower(each.key)}"
    namespace = kubernetes_namespace_v1.pihole.id
    labels = {
      app = local.app_name
    }
    annotations = {
      "metallb.io/allow-shared-ip" = "${local.app_name}-svc"
      "metallb.io/address-pool"    = kubernetes_manifest.metallb_pihole_pool.manifest.metadata.name
    }
  }

  spec {
    type             = "LoadBalancer"
    load_balancer_ip = local.external_ip

    port {
      name        = local.port_names.dns
      port        = 53
      target_port = 53
      protocol    = each.key
    }

    selector = {
      app = local.app_name
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations["metallb.io/ip-allocated-from-pool"]]
  }
}