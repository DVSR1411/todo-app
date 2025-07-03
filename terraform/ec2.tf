data "aws_subnet" "subnet_details" {
  for_each = toset(data.aws_subnets.selected.ids)
  id       = each.value
}
resource "aws_instance" "myinstance" {
  ami                    = "ami-04a37924ffe27da53"
  instance_type          = "t2.small"
  key_name               = aws_key_pair.key.id
  vpc_security_group_ids = [aws_security_group.mysg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = [for s in data.aws_subnets.selected.ids : s if data.aws_subnet.subnet_details[s].availability_zone == "ap-south-1b"][0]
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.0052"
    }
  }
  tags = {
    Name        = "jenkins"
    description = "My ec2 instance"
  }
  user_data = file("jenkins.sh")
}
resource "aws_key_pair" "key" {
  public_key = file("key.pub")
}
output "public_ip" {
  value = "${aws_instance.myinstance.public_ip}:8080"
}