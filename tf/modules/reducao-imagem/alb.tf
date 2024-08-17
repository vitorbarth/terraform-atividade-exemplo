resource "aws_default_vpc" "default" {
}

resource "aws_default_subnet" "default_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_b" {
  availability_zone = "us-east-1b"
}