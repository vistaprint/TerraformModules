variable "api" {
  description = "Identifier of the API to use."
}

variable "description" {
  description = "Deployment description."
  default = ""
}

variable "depends_id" {
  type = "list"
  description = "Dependency identifiers to the API methods related to this deployment."
  default = []
}

variable "default_stage" {
  type = "map"
  description = <<EOF
Details of the default stage. The following arguments are supported:
  - name: the name of the stage
  - description: the description of the stage
EOF
}

variable "stages" {
  type = "list"
  default = []
  description = <<EOF
List of additional stages. Each stage supports the following arguments:
  - name: the name of the stage
  - description: the description of the stage
  - cache_cluster_enabled: specifies whether a cache cluster is enabled for the stage
  - cache_cluster_size: the size of the cache cluster. See AWS or Terraform documentation for the allowed values.
  - cache_ttl_in_seconds: time to live (TTL), in seconds, for cached responses.
  - metrics_enabled: specifies whether CloudWatch metrics are enabled.
  - logging_level: specifies the logging level for this method. The available levels are OFF, ERROR, and INFO.
EOF
}
