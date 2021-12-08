

# ============ CICD bucket ============
resource "aws_s3_bucket" "cicd_bucket" {
  bucket = "tango-cicd-${terraform.workspace}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Terraform = "true"
  }

  provisioner "local-exec" {
    command = "echo -n | openssl s_client -connect github.com:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > github_cert.pem"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
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
                "AWS": "${data.terraform_remote_state.account_resources.outputs.cicd_role.arn}"
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
                "AWS": "${data.terraform_remote_state.account_resources.outputs.cicd_role.arn}"
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
  key    = "github_cert.pem"
  source = "github_cert.pem"

  depends_on = [aws_s3_bucket.cicd_bucket]
}

