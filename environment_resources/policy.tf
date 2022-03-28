data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role_${terraform.workspace}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_iam_role_policy" "ec2_role_policy" {
  name = "ec2_role_policy_${terraform.workspace}"
  role = aws_iam_role.ec2_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_role" "ecs_role" {
  name = "dynamodb_role_${terraform.workspace}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_iam_role_policy" "dynamo_policy" {
  name = "dynamo_policy_${terraform.workspace}"
  role = aws_iam_role.ecs_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "dynamodb:*",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "events:PutEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${terraform.workspace}_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_resourcegroups_group" "resource_group" {
  name = "resources_${terraform.workspace}"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::EC2::Instance",
    "AWS::ApiGateway::RestApi",
    "AWS::ApiGateway::Stage",
    "AWS::EC2::EIP",
    "AWS::EC2::VPC",
    "AWS::Elasticsearch::Domain",
    "AWS::ECS::Service",
    "AWS::Lambda::Function",
    "AWS::Logs::LogGroup",
    "AWS::RDS::DBCluster",
    "AWS::S3::Bucket",
    "AWS::SNS::Topic",
    "AWS::RDS::DBInstance",
    "AWS::RDS::ReservedDBInstance",
    "AWS::CloudWatch::Alarm"
  ],
  "TagFilters": [
    {
      "Key": "Environment",
      "Values": ["${terraform.workspace}"]
    }
  ]
}
JSON
  }
}
