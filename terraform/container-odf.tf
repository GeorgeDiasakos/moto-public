# Install ODF (OpenShift Data Foundation)
##############################################################################
resource "ibm_container_addons" "addons" {
  cluster           = ibm_container_vpc_cluster.roks_cluster.id
  resource_group_id = ibm_resource_group.group.id
  addons {
    name    = "vpc-block-csi-driver"
  }
  addons {
    name            = "openshift-data-foundation"
    version         = "4.14.0"
    parameters_json = <<PARAMETERS_JSON
    {
        "osdSize":"2000Gi",
        "numOfOsd":"1",
        "osdStorageClassName":"ibmc-vpc-block-10iops-tier",
        "odfDeploy":"true"
    }
    PARAMETERS_JSON
  }
}