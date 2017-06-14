
variable "api_name" {
  description = "The name of the API to attach the alarms to."
}

variable "stage_name" {
  description = "The stage of the API to monitor."
}

variable "alarms" {
  type = "map"
  default = {}
  description = <<EOF
Alarms information. The keys of the map are the metric names. The values
of the map contain the information for a metric alarm.

The following arguments are supported:
  - comparison_operator: The operation to use for comparing the statistic to the threshold.
    - GreaterThanOrEqualToThreshold
    - GreaterThanThreshold
    - LessThanThreshold
    - LessThanOrEqualToThreshold
  - evaluation_periods: The number of periods over which data is compared to the specified threshold.
  - period: The period in seconds over which the specified statistic is applied.
  - statistic: The statistic to apply to the alarm's associated metric.
  - threshold: The number of occurances over a given period.
  - alarm_actions: The actions to execute when the alarm transitions into an ALARM state.
      Due to a limitation in Terraform, this list must be given as a comma-separated string.
EOF
}
