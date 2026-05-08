resource "kubernetes_namespace_v1" "metallb" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = kubernetes_namespace_v1.metallb.id
}

resource "kubernetes_manifest" "metallb_pihole_pool" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"

    metadata = {
      name      = "pihole-pool"
      namespace = kubernetes_namespace_v1.metallb.id
    }

    spec = {
      addresses = [local.metallb_address_range]
    }
  }
}

resource "kubernetes_manifest" "metallb_pihole_advertisement" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"

    metadata = {
      name      = "pihole-advertisement"
      namespace = kubernetes_namespace_v1.metallb.id
    }

    spec = {
      ipAddressPools = [kubernetes_manifest.metallb_pihole_pool.manifest.metadata.name]
    }
  }
}
