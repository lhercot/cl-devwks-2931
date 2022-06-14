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

# L3 Domain
resource "aci_l3_domain_profile" "l3_peering_to_outside" {
  name                      = var.l3_domain.name
  relation_infra_rs_vlan_ns = aci_vlan_pool.peering_to_outside.id
}

resource "aci_vlan_pool" "peering_to_outside" {
  name       = var.l3_domain.name
  alloc_mode = "dynamic"
}

resource "aci_ranges" "static_range" {
  vlan_pool_dn = aci_vlan_pool.peering_to_outside.id
  from         = var.l3_domain.vlan_from
  to           = var.l3_domain.vlan_to
  alloc_mode   = "static"
}

# L3Out
resource "aci_l3_outside" "static_peering_to_outside" {
  tenant_dn                    = aci_tenant.my_tenant.id
  name                         = var.l3out.name
  relation_l3ext_rs_ectx       = aci_vrf.vrf1.id
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.l3_peering_to_outside.id
}

resource "aci_logical_node_profile" "node_1101_1102" {
  l3_outside_dn = aci_l3_outside.static_peering_to_outside.id
  name          = "node_1101_1102"
}

resource "aci_logical_node_to_fabric_node" "node_1101" {
  logical_node_profile_dn = aci_logical_node_profile.node_1101_1102.id
  tdn                     = var.l3out.side_a.node_dn
  rtr_id                  = var.l3out.side_a.rtr_id
}

resource "aci_logical_node_to_fabric_node" "node_1102" {
  logical_node_profile_dn = aci_logical_node_profile.node_1101_1102.id
  tdn                     = var.l3out.side_b.node_dn
  rtr_id                  = var.l3out.side_b.rtr_id
}

resource "aci_logical_interface_profile" "node_1101_1102" {
  logical_node_profile_dn = aci_logical_node_profile.node_1101_1102.id
  name                    = aci_logical_node_profile.node_1101_1102.name
}

resource "aci_l3out_path_attachment" "node_1101_1102_vpc_to_asr" {
  logical_interface_profile_dn = aci_logical_interface_profile.node_1101_1102.id
  target_dn                    = var.l3out.policy_group_dn
  if_inst_t                    = "ext-svi"
  encap                        = var.l3out.vlan
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_l3out_vpc_member" "side_A" {
  leaf_port_dn = aci_l3out_path_attachment.node_1101_1102_vpc_to_asr.id
  side         = "A"
  addr         = var.l3out.side_a.ip
}

resource "aci_l3out_path_attachment_secondary_ip" "side_A" {
  l3out_path_attachment_dn = aci_l3out_vpc_member.side_A.id
  addr                     = var.l3out.vip
}

resource "aci_l3out_vpc_member" "side_B" {
  leaf_port_dn = aci_l3out_path_attachment.node_1101_1102_vpc_to_asr.id
  side         = "B"
  addr         = var.l3out.side_b.ip
}

resource "aci_l3out_path_attachment_secondary_ip" "side_B" {
  l3out_path_attachment_dn = aci_l3out_vpc_member.side_B.id
  addr                     = var.l3out.vip
}

resource "aci_l3out_static_route" "node_1101_default_route" {
  fabric_node_dn = aci_logical_node_to_fabric_node.node_1101.id
  ip             = "0.0.0.0/0"
  pref           = "1"
}

resource "aci_l3out_static_route_next_hop" "node_1101_default_route_to_asr" {
  static_route_dn = aci_l3out_static_route.node_1101_default_route.id
  nh_addr         = var.l3out.gw
}

resource "aci_l3out_static_route" "node_1102_default_route" {
  fabric_node_dn = aci_logical_node_to_fabric_node.node_1102.id
  ip             = "0.0.0.0/0"
  pref           = "1"
}

resource "aci_l3out_static_route_next_hop" "node_1102_default_route_to_asr" {
  static_route_dn = aci_l3out_static_route.node_1102_default_route.id
  nh_addr         = var.l3out.gw
}

resource "aci_external_network_instance_profile" "all" {
  l3_outside_dn = aci_l3_outside.static_peering_to_outside.id
  name          = "all"
}

resource "aci_l3_ext_subnet" "subnet_0_0_0_0" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.all.id
  ip                                   = "0.0.0.0/0"
  aggregate                            = "shared-rtctrl"
  scope                                = ["import-rtctrl", "export-rtctrl", "import-security"]
}