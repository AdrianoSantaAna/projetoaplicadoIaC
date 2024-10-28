resource "aws_s3_bucket" "anaexames" {
  bucket = lower("${var.project}FE-${var.environment}")
}

resource "aws_s3_bucket_versioning" "versioning_anaExames" {
  bucket = aws_s3_bucket.anaexames.id  
  versioning_configuration {
    status = "Disabled"
  }
}
   
resource "aws_s3_bucket_website_configuration" "anaexames_StaticSite" {
  bucket = aws_s3_bucket.anaexames.id  

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_cdn" {
  bucket = aws_s3_bucket.anaexames.id
  policy = templatefile("${path.module}/s3_policies/policy_fe.json.tftpl", {
    environment    = lower(var.environment),
    project        = lower(var.project),
    cloudfront_arn = aws_cloudfront_distribution.cdn_fedistribution.arn
  })
}