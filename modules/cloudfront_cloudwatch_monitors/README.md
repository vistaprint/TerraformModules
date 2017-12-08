This module creates a set of alarms and attaches them to a cloudfront distribution. Alarms for the following metrics are supported:

* `Requests`
* `BytesDownloaded`
* `BytesUploaded`
* `TotalErrorRate`
* `4xxErrorRate`
* `5xxErrorRate`


See [Amazon CloudFront Metrics and Dimensions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cf-metricscollected.html) for more information about these metrics.

See the `variables.tf` file in the module folder for more information on the module parameters.

# Example

```hcl
module "sample_monitors" {
  source     = "git::https://github.com/vistaprint/terraformmodules.git//modules/cloudfront_cloudwatch_monitors"
  domain   = "www.example.com"
  distribution_id = "${aws_cloudfront_distribution.example_distribution.id}"

  alarms = {
    "4xxErrorRate" = {
      threshold = 5 #(%)
    }
    "5xxErrorRate" = {
      threshold = 1 #(%)
    }
  }
}
``` 

## Notes

The alarms name is prefixed with the domain name and the distributionid. For example, the `4xxError` alarm will be called `example.com-E12312QH8BVRIY-4xxErrorRate`.

Cloudfront distributions are Global but all metrics and alarms must be set in N. Virginia (us-east-1).
