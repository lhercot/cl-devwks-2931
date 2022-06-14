terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
    }
  }
}

#configure provider with your cisco aci credentials.
provider "aci" {
  username = var.apic_user     # <APIC username>
  password = var.apic_password # <APIC pwd>
  url      = var.apic          # <cloud APIC URL>
  insecure = true
}

locals {
  tenant = "${var.tenant_base.name}${var.seat_id}"
}

resource "aci_tenant" "my_tenant" {
  name = local.tenant
}

# VRF and BDs
resource "aci_vrf" "vrf1" {
  tenant_dn = aci_tenant.my_tenant.id
  name      = var.vrf.name
}

# ANP
resource "aci_application_profile" "WoS" {
  tenant_dn = aci_tenant.my_tenant.id
  name      = var.anp.name
}

# EPG VLAN 101 and 102
module "epg_bd" {
  source = "./modules/epg_bd"
  for_each = {
    for v in var.epgs : "${v.vlan_id}" => v
  }
  tenant_dn  = aci_tenant.my_tenant.id
  vrf_dn     = aci_vrf.vrf1.id
  anp_dn     = aci_application_profile.WoS.id
  vlan_id    = each.value.vlan_id
  gw         = each.value.gw
  domain_dn  = each.value.domain_dn
  interfaces = each.value.interfaces
}

module "l3_domain" {
  source    = "./modules/l3_domain"
  name      = var.l3_domain.name
  vlan_from = var.l3_domain.vlan_from
  vlan_to   = var.l3_domain.vlan_to
}

module "l3out" {
  depends_on = [module.l3_domain]
  source     = "./modules/l3out"
  for_each = {
    for v in var.l3outs : "${v.name}" => v
  }
  tenant_dn       = aci_tenant.my_tenant.id
  vrf_dn          = aci_vrf.vrf1.id
  l3_domain_dn    = module.l3_domain.l3_domain_dn
  name            = each.value.name
  logical_node    = each.value.logical_node
  policy_group_dn = each.value.policy_group_dn
  vlan            = each.value.vlan
  vip             = each.value.vip
  gw              = each.value.gw
  side_a          = each.value.side_a
  side_b          = each.value.side_b
}