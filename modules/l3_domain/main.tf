terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
    }
  }
}

resource "aci_l3_domain_profile" "l3_peering_to_outside" {
  name                      = var.name
  relation_infra_rs_vlan_ns = aci_vlan_pool.peering_to_outside.id
}

resource "aci_vlan_pool" "peering_to_outside" {
  name       = var.name
  alloc_mode = "dynamic"
}

resource "aci_ranges" "static_range" {
  vlan_pool_dn = aci_vlan_pool.peering_to_outside.id
  from         = var.vlan_from
  to           = var.vlan_to
  alloc_mode   = "static"
}
