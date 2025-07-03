data "http" "my_public_ip" {
  url = "https://ifconfig.me/ip"
}
locals {
  my_public_ip = "${chomp(data.http.my_public_ip.response_body)}/32"
}
resource "aws_security_group" "mysg" {
  name        = "mydemosg1"
  vpc_id      = data.aws_vpc.default.id
  description = "Allow inbound traffic on port 22,80,443,8080 and egress on all ports"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}