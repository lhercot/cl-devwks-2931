tenant_base = { name = "DEVWKS2931-" }
vrf    = { name = "vrf1" }
anp    = { name = "WoS" }

phys_domain_dn = "uni/phys-phys"

vlan_101_gw = "10.1.101.254/24"
vlan_101_interface_1 = "topology/pod-1/paths-101/pathep-[eth1/1]"
vlan_101_interface_2 = "topology/pod-1/paths-101/pathep-[eth1/2]"

vlan_102_gw = "10.1.102.254/24"
vlan_102_interface_1 = "topology/pod-1/paths-101/pathep-[eth1/11]"
vlan_102_interface_2 = "topology/pod-1/paths-101/pathep-[eth1/12]"

l3_domain = {
  name      = "L3_Peering_to_Outside"
  vlan_from = "vlan-100"
  vlan_to   = "vlan-105"
}

l3out = {
  name            = "Static_Peering_to_Outside"
  logical_node    = "node_1101_1102"
  policy_group_dn = "topology/pod-1/protpaths-1101-1102/pathep-[node_1101_1102_vpc_to_asr]"
  vlan            = "vlan-100"
  vip             = "10.1.0.253/24"
  gw              = "10.1.0.254"
  side_a = {
    node_dn = "topology/pod-1/node-1101"
    rtr_id  = "10.0.0.1"
    ip      = "10.1.0.1/24"
  }
  side_b = {
    node_dn = "topology/pod-1/node-1102"
    rtr_id  = "10.0.0.2"
    ip      = "10.1.0.2/24"
  }
}