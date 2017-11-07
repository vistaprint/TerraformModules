variable "table_name" {
  description = "Name of the table to add autoscale to"

}

variable "read_autoscale" {
    description = <<EOF
    Map containing read autoscale configuration
    
        default     = {
        enabled = false
        target_value       = 70
        min_capacity       = 1
        max_capacity       = 1
    }
EOF
    
    type        = "map" 
    default     = {}
}

variable "write_autoscale" {
    description = <<EOF
    Map containing write autoscale configuration
    
        default     = {
        enabled = false
        target_value       = 70
        min_capacity       = 1
        max_capacity       = 1
    }
EOF
    
    type        = "map" 
    default = {}
}