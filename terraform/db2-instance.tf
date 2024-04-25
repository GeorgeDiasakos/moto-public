##############################################################################
# Create Public Gateways for DB2 and PowerBI GW
##############################################################################

# issue - complain over quota. To be reviwed
#resource "ibm_is_public_gateway" "db2_pgw" {
#  name           = "${local.basename}-pgw-db2"
#  vpc            = ibm_is_vpc.vpc.id
#  zone           = "${var.db2_region}"
#  resource_group = ibm_resource_group.group.id
#  tags           = var.tags
#}

##############################################################################
# Create subnet for the db2 and Power BI GW
##############################################################################
resource "ibm_is_subnet" "db2_subnet" {
  name            = "${local.basename}-db2-subnet"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.db2_region}"
  ipv4_cidr_block = "${var.subnet_cidr_db2}"
  tags            = var.tags
  resource_group  = ibm_resource_group.group.id
#  network_acl     = ibm_is_network_acl.db2_acl.id
  public_gateway  = var.vpc_enable_public_gateway ? element(ibm_is_public_gateway.pgw.*.id, 1) : null


  depends_on = [ibm_is_vpc_address_prefix.address_prefix]
}


##############################################################################
# Create db2
##############################################################################

resource "ibm_is_volume" "db2_volume" {
  name           = "db2-volume"
  profile        = "5iops-tier"
  zone           = "${var.db2_region}"
  capacity       = 1000
}

resource "ibm_is_instance" "db2" {
  name    = "elp-db2"
  vpc     = ibm_is_vpc.vpc.id
  zone    = "${var.db2_region}"
  keys    = [data.ibm_is_ssh_key.ssh_key_id_db2.id]
  image   = data.ibm_is_image.image_db2.id
  profile = var.profile_name_db2
#  resource_group = var.ibm_is_resource_group_id
  user_data      = file("${path.root}/db2_config.yml")
  volumes = [ibm_is_volume.db2_volume.id]

  primary_network_interface {
    subnet = ibm_is_subnet.db2_subnet.id
  }

  boot_volume {
    name = "${local.basename}--db2-boot"
  }
}

##############################################################################
# Create VM for PowerBI GW
##############################################################################

resource "ibm_is_instance" "powerbigw" {
  name    = "elp-power-bi-gw"
  vpc     = ibm_is_vpc.vpc.id
  zone    = "${var.db2_region}"
  keys    = [data.ibm_is_ssh_key.ssh_key_id_powerbigw.id]
  image   = data.ibm_is_image.image_powerbigw.id
  profile = var.profile_name_powerbigw

  primary_network_interface {
    subnet = ibm_is_subnet.db2_subnet.id
  }

    boot_volume {
    name = "${local.basename}--powerbigw-boot"
    size = 192
  }
}

