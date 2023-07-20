locals {
  disable_traefik         = var.disable_traefik ? "--disable traefik " : ""
  disable_servicelb       = var.disable_servicelb ? "--disable servicelb " : ""
  cluster_cidr_separator  = var.pod_cidr_v4 != "" && var.pod_cidr_v6 != "" ? "," : ""
  service_cidr_separator  = var.service_cidr_v4 != "" && var.service_cidr_v6 != "" ? "," : ""
  additional_sans         = length(var.tls_sans) > 0 ? " --tls-san ${join(",", var.tls_sans)}" : ""
  allow_pods_on_control   = var.allow_pods_on_control || length(var.worker_addresses) == 0 ? true : false
}

resource "null_resource" "k3s_control" {

  provisioner "local-exec" {
    command = "k3sup install --ip ${var.control_address} --user ${var.username} --local-path ${var.kubeconfig_path} --k3s-extra-args '${local.disable_traefik}${local.disable_servicelb} --flannel-backend=${var.flannel_backend} --cluster-cidr \"${var.pod_cidr_v4}${local.cluster_cidr_separator}${var.pod_cidr_v6}\" --service-cidr \"${var.service_cidr_v4}${local.service_cidr_separator}${var.service_cidr_v6}\"${local.additional_sans}' && sleep 30"
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
    command = "k3sup join --server-ip ${var.control_address} --ip ${var.worker_addresses[count.index]} --user debian"
  }
}
