# ============ cloudtrail bucket ============
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "kahula-bucket-cloudtrail"
  acl    = "private"

  versioning {
    enabled = false
  }

  tags = {
    Terraform = "true"
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.cloudtrail_bucket.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.cloudtrail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
        }
    ]
}
POLICY
}

# ============ CICD bucket for account resources ============
resource "aws_s3_bucket" "cicd_bucket" {
  bucket = "kahula-cicd-account-resources"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Terraform = "true"
  }

  provisioner "local-exec" {
    command = "echo -n | openssl s_client -connect git.daimler.com:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > daimler_github_cert.pem"
  }
}

resource "aws_s3_bucket_public_access_block" "cicd_bucket_public_access_block" {
  bucket = aws_s3_bucket.cicd_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cicd_bucket_policy" {
  bucket     = aws_s3_bucket.cicd_bucket.id
  depends_on = [aws_s3_bucket.cicd_bucket]

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Container codebuild permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.cicd_role.arn}"
            },
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Resource": "${aws_s3_bucket.cicd_bucket.arn}"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.cicd_role.arn}"
            },
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "${aws_s3_bucket.cicd_bucket.arn}/*"
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_object" "github_cert" {
  bucket = aws_s3_bucket.cicd_bucket.id
  key    = "daimler_github_cert.pem"
  source = "daimler_github_cert.pem"

  depends_on = [aws_s3_bucket.cicd_bucket]
}
