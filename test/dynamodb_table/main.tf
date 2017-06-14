provider "aws" {
  profile    = "${var.profile}"
  region     = "${var.region}"
}

module "table" {
  source = "../../modules/dynamodb_table"
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
