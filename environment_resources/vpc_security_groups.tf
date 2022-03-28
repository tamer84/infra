resource "aws_security_group" "ssh_access" {
  name = "ssh_access-${terraform.workspace}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.tango.id

  tags = {
    Name        = "ssh-access-${terraform.workspace}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "elasticsearch_access" {
  name = "elasticsearch_access-${terraform.workspace}"

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.tango.id

  tags = {
    Name        = "elasticsearch-access-${terraform.workspace}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}


resource "aws_security_group" "https_access" {
  name        = "https_access-${terraform.workspace}"
  description = "Allow access from mb.io networks"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.tango.id

  tags = {
    Name        = "https-access-${terraform.workspace}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "internal_access" {
  name = "internal_network_access-${terraform.workspace}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.vpcs_cidr_blocks[terraform.workspace]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.tango.id

  tags = {
    Name        = "internal-access-${terraform.workspace}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}
