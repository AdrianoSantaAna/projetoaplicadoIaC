resource "aws_waf_web_acl" "waf_acl" {
  name        = "CloudFrontWAF"
  metric_name = "CloudFrontWAFMetric"

  default_action {
    type = "ALLOW"
  }

  rules {
    action {
      type = "BLOCK"
    }
    priority = 1
    rule_id  = aws_waf_rule.sql_injection_rule.id
  }

  rules {
    action {
      type = "BLOCK"
    }
    priority = 2
    rule_id  = aws_waf_rule.xss_rule.id
  }
}

resource "aws_waf_rule" "sql_injection_rule" {
  name        = "SQLInjectionRule"
  metric_name = "SQLInjection"
  predicates {
    type    = "SqlInjectionMatch"
    data_id = aws_waf_sql_injection_match_set.sql_injection_set.id
  }
}

resource "aws_waf_rule" "xss_rule" {
  name        = "XSSRule"
  metric_name = "XSSRule"
  predicates {
    type    = "XssMatch"
    data_id = aws_waf_xss_match_set.xss_set.id
  }
}

resource "aws_waf_xss_match_set" "xss_set" {
  name = "XssMatchSet"

  xss_match_tuples {
    field_to_match {
      type = "BODY"
    }
    text_transformation = "NONE"
  }
}

resource "aws_waf_sql_injection_match_set" "sql_injection_set" {
  name = "SQLInjectionSet"

  sql_injection_match_tuples {
    field_to_match {
      type = "BODY"
    }
    text_transformation = "NONE"
  }
}
