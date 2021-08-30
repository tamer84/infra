# ============ Lambda execution ============
resource "aws_iam_role" "lambda_default_exec" {
  name = "lambda_default_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "basic_lambda_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:CreateBucket",
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation",
                "es:ESHttp*",
                "sqs:SendMessage",
                "sns:Publish",
                "events:PutEvents",
                "dynamodb:BatchGetItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem",
                "firehose:PutRecord",
                "firehose:PutRecordBatch",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-default-attachment" {
  role       = aws_iam_role.lambda_default_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda-vpc-attachment" {
  role       = aws_iam_role.lambda_default_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


# ============ CICD role ============
resource "aws_iam_role" "cicd_role" {
  name = "cicd_role"
  path = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Terraform = "true"
  }
}

resource "aws_iam_role_policy" "cicd_role_policy" {
  name = "cicd_role_policy"
  role = aws_iam_role.cicd_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases"
            ],
            "Resource": [
                "arn:aws:codebuild:eu-central-1:736578946942:report-group/*"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                "application-autoscaling:*",
                "codebuild:*",
                "codepipeline:*",
                "cloudtrail:Describe*",
                "cloudtrail:List*",
                "cloudtrail:Get*",
                "cloudtrail:Update*",
                "cloudtrail:PutEventSelectors",
                "secretsmanager:GetSecretValue",
                "sns:*",
                "ssm:*",
                "sqs:*",
                "glue:*",
                "firehose:*",
                "events:*",
                "logs:*",
                "cloudwatch:*",
                "s3:*",
                "ecs:*",
                "ecr:*",
                "ec2:*",
                "autoscaling:*",
                "es:*",
                "rds:Describe*",
                "rds:List*",
                "rds:Modify*",
                "dynamodb:*",
                "elasticloadbalancing:*",
                "resource-groups:*",
                "tag:Get*",
                "iam:*",
                "access-analyzer:*",
                "acm:*",
                "cognito-idp:*",
                "apigateway:*",
                "lambda:*",
                "route53:*",
                "route53resolver:*",
                "servicediscovery:Get*",
                "servicediscovery:List*",
                "servicediscovery:CreateService",
                "servicediscovery:UpdateService",
                "servicediscovery:DeleteService",
                "servicediscovery:DeleteNamespace",
                "codeartifact:GetAuthorizationToken",
                "codeartifact:GetRepositoryEndpoint",
                "codeartifact:ReadFromRepository",
                "codeartifact:PublishPackageVersion",
                "codeartifact:PutPackageMetadata",
                "sts:GetServiceBearerToken",
                "codestar-connections:*",
                "wafv2:*"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_policy" "cloudwatch_access_policy" {
  name        = "cloudwatch-access-policy"
  description = "Policy to access cloudwatch"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# ======= Cloudtrail role for CloudWatch access ================
resource "aws_iam_role" "cloudtrail_role" {
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["cloudtrail.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cloudtrail_cw_policy_attach" {
  role       = aws_iam_role.cloudtrail_role.id
  policy_arn = aws_iam_policy.cloudwatch_access_policy.arn
}

# ============================================================================

resource "aws_accessanalyzer_analyzer" "iam_access_analyzer" {
  analyzer_name = "AWS-Access"
  tags = {
    "Terraform" = "true"
  }
}
