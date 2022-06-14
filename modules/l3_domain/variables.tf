variable "name" {
  description = "L3 Domain Name"
  type        = string
}

variable "vlan_from" {
  description = "L3 Domain VLAN range from"
  type        = string
  default     = 1
}

variable "vlan_to" {
  description = "L3 Domain VLAN range to"
  type        = string
  default     = 4094
}