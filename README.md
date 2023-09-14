# Example Terraform module

Terraform module to create a k3s cluster using k3sup.

## Usage

```hcl
module "k3s" {
  source                  = "github.com/sncs-uk/terraform-k3sup"
  control_address         = "10.20.30.40"
  worker_addresses        = ["10.20.30.41", "10.20.30.42"]
  username                = "debian"
  disable_traefik         = true
  disable_servicelb       = true
  disable_network_policy  = true
  pod_cidr_v4             = "10.42.0.0/16"
  pod_cidr_v6             = "2001:0db8::/61"
  node_cidr_mask_size_v4  = 24
  node_cidr_mask_size_v6  = 64
  service_cidr_v4         = "10.43.0.0/16"
  service_cidr_v6         = "2001:0db8:100::/108"
  tls_sans                = ["my-kubernetes.example.com"]
  flannel_backend         = "vxlan"
  kubeconfig_path         = "kubeconfig"
  allow_pods_on_control   = false
  ssh_key_path            = "/home/user/.ssh/id_rsa"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_k3sup"></a> [k3sup](#requirement\_k3sup) | >= 0.12 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.27.3 |
