provider "aws" {
  profile = "${var.profile}"
  region  = "us-east-1"
}

###############################################################
# CLOUDFRONT
###############################################################

resource "aws_cloudfront_distribution" "example_distribution" {  

  origin {
    domain_name      = "www.example.com"
    origin_id        = "example_origin"

    custom_origin_config {
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1"]
      http_port = 80
      https_port = 443
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution TDK Test infrastructure."
  default_root_object = "/"

  aliases = []

  default_cache_behavior {
    allowed_methods  = ["HEAD", "OPTIONS", "GET"]
    cached_methods   = ["HEAD", "OPTIONS", "GET"]
    target_origin_id = "example_origin"

    forwarded_values {
      query_string = true

      query_string_cache_keys = ["url-version", "requester"]

      cookies {
        forward = "none"
      }
    }
	compress			   = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 300
    default_ttl            = 2629744
    max_ttl                = 31536000
  }

  #Required
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
   
  tags = {
    App = "TDK"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

###############################################################
# CLOUDFRONT ALARMS
###############################################################

module "cloudfront_cloudwatch_alarms" {
  source = "../../modules/cloudfront_cloudwatch_monitors"

  domain   = "www.example.com"
  distribution_id = "${aws_cloudfront_distribution.example_distribution.id}"
  # TODO: remove once https://github.com/hashicorp/terraform/issues/15471 gets fixed.
  alarm_count = 2
  alarms = {
    "4xxErrorRate" = {
      threshold = 1 #(%)
    }
    "5xxErrorRate" = {
      threshold = 1 #(%)
    }
  }
}