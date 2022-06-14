terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
    }
  }
}

resource "aci_l3_outside" "static_peering_to_outside" {
  tenant_dn                    = var.tenant_dn
  name                         = var.name
  relation_l3ext_rs_ectx       = var.vrf_dn
  relation_l3ext_rs_l3_dom_att = var.l3_domain_dn
}

resource "aci_logical_node_profile" "nodes" {
  l3_outside_dn = aci_l3_outside.static_peering_to_outside.id
  name          = var.logical_node
}

resource "aci_logical_node_to_fabric_node" "node_1" {
  logical_node_profile_dn = aci_logical_node_profile.nodes.id
  tdn                     = var.side_a.node_dn
  rtr_id                  = var.side_a.rtr_id
}

resource "aci_logical_node_to_fabric_node" "node_2" {
  logical_node_profile_dn = aci_logical_node_profile.nodes.id
  tdn                     = var.side_b.node_dn
  rtr_id                  = var.side_b.rtr_id
}

resource "aci_logical_interface_profile" "nodes" {
  logical_node_profile_dn = aci_logical_node_profile.nodes.id
  name                    = aci_logical_node_profile.nodes.name
}

resource "aci_l3out_path_attachment" "nodes_vpc_to_asr" {
  logical_interface_profile_dn = aci_logical_interface_profile.nodes.id
  target_dn                    = var.policy_group_dn
  if_inst_t                    = "ext-svi"
  encap                        = var.vlan
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_l3out_vpc_member" "side_A" {
  leaf_port_dn = aci_l3out_path_attachment.nodes_vpc_to_asr.id
  side         = "A"
  addr         = var.side_a.ip
}

resource "aci_l3out_path_attachment_secondary_ip" "side_A" {
  l3out_path_attachment_dn = aci_l3out_vpc_member.side_A.id
  addr                     = var.vip
}

resource "aci_l3out_vpc_member" "side_B" {
  leaf_port_dn = aci_l3out_path_attachment.nodes_vpc_to_asr.id
  side         = "B"
  addr         = var.side_b.ip
}

resource "aci_l3out_path_attachment_secondary_ip" "side_B" {
  l3out_path_attachment_dn = aci_l3out_vpc_member.side_B.id
  addr                     = var.vip
}

resource "aci_l3out_static_route" "node_1_default_route" {
  fabric_node_dn = aci_logical_node_to_fabric_node.node_1.id
  ip             = "0.0.0.0/0"
  pref           = "1"
}

resource "aci_l3out_static_route_next_hop" "node_1_default_route_to_asr" {
  static_route_dn = aci_l3out_static_route.node_1_default_route.id
  nh_addr         = var.gw
}

resource "aci_l3out_static_route" "node_2_default_route" {
  fabric_node_dn = aci_logical_node_to_fabric_node.node_2.id
  ip             = "0.0.0.0/0"
  pref           = "1"
}

resource "aci_l3out_static_route_next_hop" "node_2_default_route_to_asr" {
  static_route_dn = aci_l3out_static_route.node_2_default_route.id
  nh_addr         = "10.1.0.254"
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