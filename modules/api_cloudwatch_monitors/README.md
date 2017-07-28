This module creates a set of alarms and attaches them to a specific API Gateway stage. Alarms for the following metrics are supported:

* `4XXError`
* `5XXError`
* `CacheHitCount`
* `CacheMissCount`
* `Count`
* `IntegrationLatency`
* `Latency`

See [Amazon API Gateway Metrics and Dimensions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/api-gateway-metrics-dimensions.html) for more information about these metrics.

See the `variables.tf` file in the module folder for more information on the module parameters.

# Example

```hcl
module "sample_monitors" {
  source     = "git::https://github.com/betabandido/terraformmodules.git//modules/api_cloudwatch_monitors"
  api_name   = "SampleApi"
  stage_name = "Prod" 

  alarms = {
    "4XXError" = {
      threshold = 100
    }
    "5XXError" = {
      threshold = 25
    }
    "Latency" = {
      statistic = "Average"
    }
    "CacheMissCount" = {}
  }
}
``` 

## Notes

The alarms name is prefixed with the api and the stage names. For example, the `4XXError` alarm will be called `SampleApi_Prod_4XXError`.
