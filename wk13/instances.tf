data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
resource "aws_instance" "web" {
  count         = var.web_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.web_instance_type
  subnet_id     = element(values(aws_subnet.public)[*].id, count.index % length(aws_subnet.public))
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name      = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y httpd
              echo "<h1>${local.name_prefix}-web-${count.index}</h1>" > /var/www/html/index.html
              systemctl enable --now httpd
              EOF

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-${count.index}"
  })
}
