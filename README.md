# pihole-k8s

This repository takes the [mojo2600 pihole-kubernetes](https://github.com/MoJo2600/pihole-kubernetes/tree/main) repo, pulls only the parts I need for my home setup, and converts it to a Terraform repo rather than Helm.

## Values you need to configure
You will need to configure these values in `main.tf`:
- `external_ip`: The IP address you want to advertise your Pihole web and DNS servers on. It should be reserved.
- `gateway_ip`: The IP address of your gateway or router or whatever you're using as a local DNS server.
- `metallb_address_range`: The range of IP addresses you want MetalLB to use. For example, if you have 2 Raspberry Pis at `192.168.1.10` and `192.168.1.11`, you'd put `192.168.1.10-192.168.1.11`.

## Deployment

### Creating the web password
You'll need to create a password in your cluster first before applying the TF plan. You can do so by calling:
```
kubectl create secret generic pihole-web-password --from-literal=password=MySuperSecretPassword123
```

Keeping the password in plaintext in K8s isn't ideal, yeah, but this is just a silly local project. If you really want to lock down your password then you can do something like:
1. Store the password in a secrets store like Vault
2. Install the Secrets Store CSI driver to your cluster
3. Mount the secret as a file
4. Use the `WEBPASSWORD_FILE` env var to point Pihole at the secret file

### Deploying the stack
You can deploy the whole thing at once by calling `terraform plan` and, if the plan looks good, `terraform apply`.