provider "aws" {
  profile    = "${var.profile}"
  region     = "${var.region}"
}

locals {
    table_info = [
    {
      name = "${var.prefix}Table1"
    },
    {
      name = "${var.prefix}Table2"
      read_capacity = 2
      write_capacity = 2
    },
  ]
}

module "table" {
  source = "../../modules/dynamodb_table"
  table_info = "${local.table_info}"
}

module "autoscale" {
    source = "../../modules/dynamodb_autoscale"

    table_name = "${element(module.table.names, 1)}"

    read_autoscale = {
        enabled = true

        # if min/max capacity is changed, target_value has to also be changed due to dependency not working
        # broken: will get fixed with https://github.com/terraform-providers/terraform-provider-aws/issues/538
        target_value = 50
        min_capacity = "${lookup(local.table_info[1], "read_capacity")}"
        max_capacity = 20
    }
}