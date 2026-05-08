terraform {
  backend "local" {
    path = "./state/terraform.tfstate"
  }

  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

locals {
  app_name = "pihole"
  port_names = {
    dns   = "dns"
    http  = "http"
    https = "https"
  }

  external_ip = "192.168.1.15"
  gateway_ip  = "192.168.1.253"

  metallb_address_range = "192.168.1.14-192.168.1.19"
}