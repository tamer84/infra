resource "aws_iam_user" "vpp-user" {
  name = "vpp_user_${terraform.workspace}"
  path = "/service/"

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "vpp-${terraform.workspace}"
  }
}

resource "aws_iam_access_key" "vpp" {
  user = aws_iam_user.vpp-user.name
}

resource "aws_iam_user_policy" "vpp-es-access" {
  name = "vpp-user-${terraform.workspace}"
  user = aws_iam_user.vpp-user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "es:*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "dynamodb:*",
        "cloudwatch:PutMetricData"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

