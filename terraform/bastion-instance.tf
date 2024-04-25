
##############################################################################
# Create subnet for the bastion
##############################################################################
resource "ibm_is_subnet" "bastion_subnet" {
  name            = "${local.basename}-bastion-subnet"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.bastion_region}"
  ipv4_cidr_block = "${var.subnet_cidr_bastion}"
  tags            = var.tags
  resource_group  = ibm_resource_group.group.id
#  network_acl     = ibm_is_network_acl.bastion_acl.id

  depends_on = [ibm_is_vpc_address_prefix.address_prefix]
}

##############################################################################
# Create bastion
##############################################################################
resource "ibm_is_instance" "bastion" {
  name           = "elp-bastion-${var.bastion_region}"
  vpc            = ibm_is_vpc.vpc.id
  zone           = "${var.bastion_region}"
  keys           = [data.ibm_is_ssh_key.ssh_key_id_bastion.id]
  image          = data.ibm_is_image.image_bastion.id
  profile        = var.profile_name_bastion
#  resource_group = var.ibm_is_resource_group_id
  user_data      = file("${path.root}/bastion_config.yml")
  tags           = var.tags


  primary_network_interface {
    subnet       = ibm_is_subnet.bastion_subnet.id
#    security_groups = [ibm_is_security_group.bastion.id]
  }

  boot_volume {
    name         = "${local.basename}-boot"
  }
}

##############################################################################
# Create floating IP for the bastion (expose SSH)
##############################################################################
resource "ibm_is_floating_ip" "bastion" {
#  count         = var.bastion_count
  name          = "elp-bastion-float-ip-${var.bastion_region}"
  target        = ibm_is_instance.bastion.primary_network_interface[0].id
  tags          = var.tags
}
