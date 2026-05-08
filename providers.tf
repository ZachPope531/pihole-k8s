provider "kubernetes" {
  config_path    = "${path.module}/state/cluster_config"
  config_context = "default"
}

provider "helm" {
  kubernetes = {
    config_path    = "${path.module}/state/cluster_config"
    config_context = "default"
  }
}