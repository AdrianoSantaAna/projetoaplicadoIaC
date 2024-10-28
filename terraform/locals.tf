locals {
    waf_enabled = var.waf_enabled ? 1 : 0
    waf_id = var.waf_enabled ? resource.aws_wafv2_web_acl.waf[0].arn : null
    cors_allowed = [
    "http://${var.cloudfront_url}",
    "https://${var.cloudfront_url}"
  ]
}