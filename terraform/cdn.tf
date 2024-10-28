resource "aws_cloudfront_origin_access_control" "anaexames_oac" {
  name                              = "AnaExamesBucketAccessControl"
  description                       = "Access Control for AnaExames S3 Bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "cdn_fedistribution" {
  origin {
    domain_name = aws_s3_bucket.anaexames.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.anaexames_oac.id
    origin_id                = "anaexamesfe"
  }


  origin {
    domain_name = replace(replace(aws_api_gateway_deployment.api_deploy.invoke_url, "https://", ""), "/Dev", "")
    origin_id   = "anaexames-api"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "WebSite"
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "anaexamesfe"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

 
  ordered_cache_behavior {
    path_pattern = "/api/*"
    allowed_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD", "PATCH"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "anaexames-api"

    forwarded_values {
      query_string = true
      headers      = ["Authorization"]
      
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["BR"]
    }
  }

  tags = {
    Environment = "${var.environment}"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
