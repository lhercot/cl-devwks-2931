variable "tenant_dn" {
  description = "ACI Tenant DN"
  type        = string
}

variable "anp_dn" {
  description = "ACI ANP DN"
  type        = string
}

variable "vrf_dn" {
  description = "ACI VRF DN"
  type        = string
}

variable "vlan_id" {
  description = "VLAN ID"
  type        = string
}

variable "gw" {
  description = "IP of GW for BD"
  type        = string
}

variable "domain_dn" {
  description = "DN of the Physical Domain to associate with EPG"
  type        = string
}

variable "interfaces" {
  description = "DNs of the Physical Interfaces to associate with EPG"
  type        = list(string)
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
