##############################################################################
# Account Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "APIkey that's associated with the account to provision resources to"
  type        = string
  default     = ""
  sensitive   = true
}

variable "prefix" {
  type        = string
  default     = "moto"
  description = "A prefix for all resources to be created. If none provided a random prefix will be created"
}

resource "random_string" "random" {
  count = var.prefix == "" ? 1 : 0

  length  = 6
  special = false
}

locals {
  basename = lower(var.prefix == "" ? "elp-${random_string.random.0.result}" : var.prefix)
}

variable "region" {
  description = "IBM Cloud region where all resources will be provisioned (e.g. eu-de)"
  default     = "eu-de"
}

variable "icr_region" {
  description = "IBM Container Registry Region (e.g. de.icr.io)"
  default     = "de.icr.io"
}

variable "tags" {
  description = "List of Tags"
  type        = list(string)
  default     = ["tf", "moto"]
}

# Account ID is required for CBR (Context Based Restrictions) and SCC scope
##############################################################################
data "ibm_iam_auth_token" "tokendata" {}
data "ibm_iam_account_settings" "account_settings" {}

locals {
  account_id = data.ibm_iam_account_settings.account_settings.account_id
}

##############################################################################

############################
# VARIABLES FOR BASTION VSIs 
############################

variable "bastion_region" {
  description = "Region where bastion will be deployed"
  default     = "eu-de-1"
}

variable "subnet_cidr_bastion" {
  description = "CIDR blocks for bastion subnet"
  default = "10.9.1.32/28"
}

variable "ssh_key_bastion" {
  type        = string
  default     = "moto-ssh"
}

data "ibm_is_ssh_key" "ssh_key_id_bastion" {
    name = var.ssh_key_bastion
}

variable "image_name_bastion" {
  type        = string
  default     = "ibm-ubuntu-20-04-6-minimal-amd64-3"
  description = "Name of the image to use for the bastion VSI"
}

variable "profile_name_bastion" {
  type        = string
  description = "Instance profile to use for the bastion VSI"
  default     = "bx2-4x16"
}

data "ibm_is_image" "image_bastion" {
  name = var.image_name_bastion
}


############################
# VARIABLES FOR DB2 VSI
############################

variable "db2_region" {
  description = "Region where bastion will be deployed"
  default     = "eu-de-2"
}

variable "subnet_cidr_db2" {
  description = "CIDR blocks for DB2 subnet"
  default = "10.9.1.32/28"
}

variable "ssh_key_db2" {
  type        = string
  default     = "moto-ssh-db2"
}

data "ibm_is_ssh_key" "ssh_key_id_db2" {
    name = var.ssh_key_db2
}

variable "image_name_db2" {
  type        = string
  default     = "ibm-redhat-9-2-minimal-amd64-3"
  description = "Name of the image to use for the DB2 VSI"
}

variable "profile_name_db2" {
  type        = string
  description = "Instance profile to use for the DB2 VSI"
  default     = "mx2-4x32"
}

data "ibm_is_image" "image_db2" {
  name = var.image_name_db2
}


############################
# VARIABLES FOR POWER BI GW VSI
############################

variable "ssh_key_powerbigw" {
  type        = string
  default     = "moto-ssh-powerbigw"
}

data "ibm_is_ssh_key" "ssh_key_id_powerbigw" {
    name = var.ssh_key_powerbigw 
}

variable "image_name_powerbigw" {
  type        = string
  default     = "ibm-windows-server-2019-full-standard-amd64-16"
  description = "Name of the image to use for the Power BI GW VSI"
}

variable "profile_name_powerbigw" {
  type        = string
  description = "Instance profile to use for the Power BI GW VSI"
  default     = "bx2-4x16"
}

data "ibm_is_image" "image_powerbigw" {
  name = var.image_name_powerbigw
}

############################
# VARIABLES FOR Reserved subnet
############################

variable "subnet_cidr_reserved" {
  description = "CIDR blocks for reserved subnet"
  default = "10.9.1.32/28"
}


##############################################################################
