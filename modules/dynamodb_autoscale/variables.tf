variable "table_name" {
  description = "Name of the table to add autoscale to"
}

variable "read_autoscale" {
  description = <<EOF
    Map containing read autoscale configuration
    
    default = {
        enabled = false
        target_value       = 70
        min_capacity       = 1
        max_capacity       = 1
    }
EOF

  type    = "map"
  default = {}
}

variable "write_autoscale" {
  description = <<EOF
    Map containing write autoscale configuration
    
    default = {
        enabled = false
        target_value       = 70
        min_capacity       = 1
        max_capacity       = 1
    }
EOF

  type    = "map"
  default = {}
}

variable "create_role" {
  description = "Whether to create a specific role and policy"

  default = true
}

variable "role_arn" {
  description = "Role ARN to use (if empty a new role will be created)"

  default = ""
}

variable "policy_id" {
  description = "Role policy id to depend on"

  default = ""
}
