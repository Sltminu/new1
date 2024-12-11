provider "aws"{
    region="eu-west-1"
}
resource "aws_security_group" "ssh_access" {
    name="allow ssh_access"
    description = "allow ssh_access from specific ip"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["37.228.209.233/32"]
        
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]

    }
    
  
}
resource "aws_instance" "myserver" {
    ami=data.aws_ami.amazon_linux_2.id
    instance_type = "t3.micro"
    key_name = "mykeypair"
    vpc_security_group_ids = [aws_security_group.ssh_access.id]

root_block_device {
  volume_type="gp3"
  volume_size = 30
}

  tags = {
    Name = "myserver"
  }
}
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.myserver.id
  domain = "vpc"
}
resource "aws_eip_association" "eip_association" {
  instance_id   = aws_instance.myserver.id
  allocation_id = aws_eip.elastic_ip.id
}

  

  data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
output "instance_id" {
    value = aws_instance.myserver.id
  
}
output "public_ip" {
    value = aws_instance.myserver.public_ip
  
}

