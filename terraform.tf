locals {
  disable_traefik         = var.disable_traefik ? "--disable traefik " : ""
  disable_servicelb       = var.disable_servicelb ? "--disable servicelb " : ""
  disable_network_policy  = var.disable_network_policy ? "--disable-network-policy " : ""
  cluster_cidr_separator  = var.pod_cidr_v4 != "" && var.pod_cidr_v6 != "" ? "," : ""
  service_cidr_separator  = var.service_cidr_v4 != "" && var.service_cidr_v6 != "" ? "," : ""
  additional_sans         = length(var.tls_sans) > 0 ? " --tls-san ${join(",", var.tls_sans)}" : ""
  allow_pods_on_control   = var.allow_pods_on_control || length(var.worker_addresses) == 0 ? true : false
  ssh_key                 = var.ssh_key_path == null ? "" : "--ssh-key ${var.ssh_key_path}"
  node_cidr_size_v4       = var.node_cidr_mask_size_v4 == null ? "" : "--kube-controller-manager-arg=node-cidr-mask-size-ipv4=${var.node_cidr_mask_size_v4} "
  node_cidr_size_v6       = var.node_cidr_mask_size_v6 == null ? "" : "--kube-controller-manager-arg=node-cidr-mask-size-ipv6=${var.node_cidr_mask_size_v6} "
}

resource "null_resource" "k3s_control" {

  provisioner "local-exec" {
    command = "k3sup install --ip ${var.control_address} --user ${var.username} --local-path ${var.kubeconfig_path} ${local.ssh_key} --k3s-extra-args '${local.disable_traefik}${local.disable_servicelb}${local.disable_network_policy}${local.node_cidr_size_v4}${local.node_cidr_size_v6} --flannel-backend=${var.flannel_backend} --cluster-cidr \"${var.pod_cidr_v4}${local.cluster_cidr_separator}${var.pod_cidr_v6}\" --service-cidr \"${var.service_cidr_v4}${local.service_cidr_separator}${var.service_cidr_v6}\"${local.additional_sans}' && sleep 30"
  }
}

resource null_resource "k3s_taint_control" {

  depends_on = [
    null_resource.k3s_control
  ]
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "kubeconfig"
    }
    command = local.allow_pods_on_control ? "echo 'Not tainting control'" : "kubectl taint nodes $(kubectl get nodes -o=jsonpath='{.items[0].metadata.name}') node-role.kubernetes.io/master=:NoSchedule"
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "kubeconfig"
    }
    command = local.allow_pods_on_control ? "echo 'Not tainting control'" : "kubectl taint nodes $(kubectl get nodes -o=jsonpath='{.items[0].metadata.name}') node-role.kubernetes.io/control-plane=:NoSchedule"
  }
}

resource null_resource "k3s_worker" {
  count           = length(var.worker_addresses)
  depends_on = [
    null_resource.k3s_control
  ]

  provisioner "local-exec" {
    command = "k3sup join --server-ip ${var.control_address} --ip ${var.worker_addresses[count.index]} --user ${var.username} ${local.ssh_key} "
  }
}
