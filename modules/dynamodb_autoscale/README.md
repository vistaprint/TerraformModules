This module adds autoscaling to a DynamoDB table

# Example

```hcl

module "tables" {
  source = "git::https://github.com/vistaprint/terraformmodules.git//modules/dynamodb_table"
  table_info = [
    {
      name = "${var.prefix}Table1"
    },
    {
      name = "${var.prefix}Table2"
      read_capacity = 2
      write_capacity = 2
    }
}

module "autoscale" {
    source = "git::https://github.com/vistaprint/terraformmodules.git//modules/dynamodb_autoscale"

    table_name = "${element(module.table.names, 1)}"

    read_autoscale = {
        enabled = true

        # if min/max capacity is changed, target_value has to also be changed due to dependency not working
        # broken: will get fixed with https://github.com/terraform-providers/terraform-provider-aws/issues/538
        target_value = 50
        min_capacity = 2
        max_capacity = 20
    }
}

```
