This module creates a number of identical dynamodb tables given a list of table names.

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
```
