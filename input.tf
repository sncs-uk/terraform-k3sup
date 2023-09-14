variable control_address {
  type        = string
  description = "The IP address of the control node."
}
variable worker_addresses {
  type        = list(string)
  description = "The IP addresses of the worker nodes, if any."
  default     = []
}
variable username {
  type        = string
  description = "The username to use when connecting to the nodes."
  default     = "debian"
}

variable disable_traefik {
  type        = bool
  description = "Whether to disable in-built Traefik or not."
  default     = false
}

variable disable_servicelb {
  type        = bool
  description = "Whether to disable in-built servicelb or not."
  default     = false
}

variable disable_network_policy {
  type        = bool
  description = "Whether to disable in-built network policy or not."
  default     = false
}

variable pod_cidr_v4 {
  type        = string
  description = "The v4 CIDR address for the pods in the cluster."
  default     = "10.42.0.0/16"
}
variable pod_cidr_v6 {
  type        = string
  description = "The v6 CIDR address for the pods in the cluster."
  default     = ""
}

variable node_cidr_mask_size_v4 {
  type        = number
  description = "The size of IPv4 subnet to assign to each node from the pod cidr supernet."
  default     = null
}

variable node_cidr_mask_size_v6 {
  type        = number
  description = "The size of IPv6 subnet to assign to each node from the pod cidr supernet."
  default     = null
}

variable service_cidr_v4 {
  type        = string
  description = "The v4 CIDR address for the services in the cluster."
  default     = "10.43.0.0/16"
}
variable service_cidr_v6 {
  type        = string
  description = "The v6 CIDR address for the services in the cluster."
  default     = ""
}

variable tls_sans {
  type        = list(string)
  description = "Additional SAN(s) to pass to k3s for the API certificate."
  default     = []
}

variable flannel_backend {
  type        = string
  description = "The flannel backend to use."
  default     = "vxlan"
}

variable kubeconfig_path {
  type        = string
  description = "The local path which to save the kubeconfig."
  default     = "kubeconfig"
}

variable allow_pods_on_control {
  type        = bool
  description = "Allow the control plane to run pods."
  default     = false
}

variable ssh_key_path {
  type        = string
  description = "Path to the SSH Key file on the local filesystem."
  default     = null
}
