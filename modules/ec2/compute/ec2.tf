
resource "aws_instance" "ec2_instance" {
  count                  = 1
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  user_data              = var.user_data

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = var.instance_name
  }

  credit_specification {
    cpu_credits = "standard"
  }
}