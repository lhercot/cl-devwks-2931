terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
    }
  }
}

resource "aci_bridge_domain" "vlan" {
  tenant_dn          = var.tenant_dn
  name               = "Vlan-${var.vlan_id}"
  relation_fv_rs_ctx = var.vrf_dn
}

resource "aci_subnet" "vlan" {
  parent_dn = aci_bridge_domain.vlan.id
  ip        = var.gw
}

resource "aci_application_epg" "vlan" {
  application_profile_dn = var.anp_dn
  name                   = "Vlan-${var.vlan_id}"
  relation_fv_rs_bd      = aci_bridge_domain.vlan.id
  pref_gr_memb           = "include"
}

resource "aci_epg_to_domain" "vlan" {
  application_epg_dn = aci_application_epg.vlan.id
  tdn                = var.domain_dn
}

resource "aci_epg_to_static_path" "vlan" {
  for_each           = toset(var.interfaces)
  application_epg_dn = aci_application_epg.vlan.id
  encap              = "vlan-${var.vlan_id}"
  mode               = "regular"
  tdn                = each.key
}

