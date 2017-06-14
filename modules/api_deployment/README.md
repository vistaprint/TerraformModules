This module creates an API gateway deployment.

See the `variables.tf` file in the module folder for more information on the module parameters. The parameters describing a stage are directly passed to the corresponding Terraform resource. See the following documentation for more information on these parameters: [stage documentation](https://www.terraform.io/docs/providers/aws/r/api_gateway_stage.html) and [method settings documentation](https://www.terraform.io/docs/providers/aws/r/api_gateway_method_settings.html).

# Example

```
resource "aws_api_gateway_rest_api" "api" {
 name = "${var.prefix}ApiMethod"
}

module "sample_method" {
  source = "git::https://github.com/betabandido/terraformmodules.git//modules/api_method"
  api    = "${aws_api_gateway_rest_api.api.id}"
  parent = "${aws_api_gateway_rest_api.api.root_resource_id}"
  # ...
}

module "sample_deployment" {
  source     = "git::https://github.com/betabandido/terraformmodules.git//modules/api_deployment"
  api        = "${aws_api_gateway_rest_api.api.id}"
  depends_id = ["${module.method.depends_id}"]
  
  default_stage = {
    name = "Default"
    description = "Default stage"
  }
  stages = [
    {
      name = "Cached"
      description = "Stage with caching and CloudWatch metrics enabled"
      cache_cluster_enabled = true
      metrics_enabled = true
    }
  ]
}
```

# Limitations

* Only works for `GET` methods

# Usage Guidelines

## Default Stage

Due to limitations in Terraform and/or in the AWS SDK for Go, it is currently not possible to enable caching or CloudWatch metrics for the default stage. If caching or detailed metrics are desired, an additional stage must be created (see the previous example).

## Dependencies to Other Modules  

An API gateway deployment typically will depend on having the API gateway method completely constructed before the deployment resource is created. Due to a current limitation in Terraform, it is not possible to simply use `depends_on` in the deployment module to refer to one or several instances of the API method module.

As a workaround, an alternative dependency mechanism is provided. Such mechanism is composed of two different parts:

* An input parameter named `depends_id` in the API deployment module
* An output parameter also named `depends_id` in the API method module

By passing the `depends_id` output into the deployment module, the required dependency is created. If the deployment exposes multiple methods, then a list gathering all the `depends_id` outputs from the API methods should be passed to the deployment module.

As a side effect of this dependency mechanism, a dummy stage variable is created in the default stage. It is safe to ignore that variable.
