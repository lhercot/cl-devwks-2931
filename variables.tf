variable "seat_id" {
  type        = string
  default = "XX"
}

variable "tenant_base" {
  description = "ACI Tenant information"
  type        = map(any)
  default = {
    name = "DEVWKS2931-"
  }
}

variable "vrf" {
  description = "ACI VRF information"
  type        = map(any)
  default = {
    name = "vrf1"
  }
}

variable "anp" {
  description = "ACI ANP information"
  type        = map(any)
  default = {
    name = "WoS"
  }
}

variable "l3_domain" {
  description = "ACI L3Out information"
  type        = map(any)
}

variable "l3outs" {
  description = "ACI L3Out information"
  type = list(object({
    name            = string
    logical_node    = string
    policy_group_dn = string
    vlan            = string
    vip             = string
    gw              = string
    side_a = object({
      node_dn = string
      rtr_id  = string
      ip      = string
    })
    side_b = object({
      node_dn = string
      rtr_id  = string
      ip      = string
    })
  }))
}

variable "epgs" {
  type = list(object({
    vlan_id    = string
    gw         = string
    domain_dn  = string
    interfaces = list(string)
  }))
}

variable "apic" {
  default = "https://sandboxapicdc.cisco.com"
}
variable "apic_user" {
  default = "admin"
}
variable "apic_password" {}
