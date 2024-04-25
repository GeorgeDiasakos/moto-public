##############################################################################
# Create Public Gateways for DB2 and PowerBI GW
##############################################################################

# issue - complain over quota. To be reviwed
#resource "ibm_is_public_gateway" "db2_pgw" {
#  name           = "${local.basename}-pgw-db2"
#  vpc            = data.ibm_is_vpc.vpc.id
#  zone           = "${var.db2_region}"
#  resource_group = ibm_resource_group.group.id
#  tags           = var.tags
#}




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
  vpc     = data.ibm_is_vpc.vpc.id
  zone    = "${var.db2_region}"
  keys    = [data.ibm_is_ssh_key.ssh_key_id_db2.id]
  image   = data.ibm_is_image.image_db2.id
  profile = var.profile_name_db2
#  resource_group = var.ibm_is_resource_group_id
  user_data      = file("${path.root}/db2_config.yml")
  volumes = [ibm_is_volume.db2_volume.id]

  primary_network_interface {
    subnet = ibm_is_subnet.bastion_subnet.id
  }

  boot_volume {
    name = "${local.basename}--db2-boot"
  }
}

##############################################################################
# Create VM for PowerBI GW
##############################################################################

resource "ibm_is_instance" "powerbigw" {
  name    = "moto-power-bi-gw"
  vpc     = data.ibm_is_vpc.vpc.id
  zone    = "${var.db2_region}"
  keys    = [data.ibm_is_ssh_key.ssh_key_id_powerbigw.id]
  image   = data.ibm_is_image.image_powerbigw.id
  profile = var.profile_name_powerbigw

  primary_network_interface {
    subnet = ibm_is_subnet.bastion_subnet.id
  }

    boot_volume {
    name = "${local.basename}--powerbigw-boot"
    size = 192
  }
}

