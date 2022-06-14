variable "tenant_dn" {
  description = "ACI Tenant DN"
  type        = string
}

variable "vrf_dn" {
  description = "ACI VRF DN"
  type        = string
}

variable "l3_domain_dn" {
  description = "ACI L3 Domain DN"
  type        = string
}

variable "name" {
  description = "L3Out Name"
  type        = string
}

variable "logical_node" {
  description = "L3Out Logical Node name"
  type        = string
}

variable "policy_group_dn" {
  description = "Policy Group DN to be used for the VPC attachment"
  type        = string
}

variable "vlan" {
  description = "L3Out attachment VLAN"
  type        = string
}

variable "gw" {
  description = "IP of GW for default route"
  type        = string
}

variable "vip" {
  description = "Share IP between VPC members"
  type        = string
}

variable "side_a" {
  description = "VPC Side A information"
  type        = map(any)
  default = {
    node_dn = "topology/pod-1/node-1101"
    rtr_id  = "10.0.0.1"
    ip      = "10.1.0.1/24"
  }
}

variable "side_b" {
  description = "VPC Side B information"
  type        = map(any)
  default = {
    node_dn = "topology/pod-1/node-1102"
    rtr_id  = "10.0.0.2"
    ip      = "10.1.0.1/24"
  }
}
