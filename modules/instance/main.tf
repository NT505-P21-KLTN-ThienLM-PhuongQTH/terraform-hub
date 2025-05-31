resource "aws_network_interface" "main" {
  count             = length(var.instances)

  subnet_id         = var.instances[count.index].subnet_id == null ? var.subnet_id : var.instances[count.index].subnet_id
  private_ips       = var.instances[count.index].private_ips
  security_groups   = var.instances[count.index].security_groups == null ? var.security_groups : var.instances[count.index].security_groups
  source_dest_check = var.instances[count.index].source_dest_check == null ? true : var.instances[count.index].source_dest_check

  tags = {
    Name = var.instances[count.index].name
  }
}

resource "aws_instance" "main" {
  count         = length(var.instances)

  ami           = var.instances[count.index].ami == null ? var.ami : var.instances[count.index].ami
  instance_type = var.instances[count.index].instance_type == null ? var.instance_type : var.instances[count.index].instance_type
  
  key_name               = var.instances[count.index].key_name == null ? var.key_name : var.instances[count.index].key_name
  user_data              = var.instances[count.index].user_data

  network_interface {
    network_interface_id = aws_network_interface.main[count.index].id
    device_index         = 0
  }

  root_block_device {
    volume_size = var.instances[count.index].ebs_size == null ? var.ebs_size : var.instances[count.index].ebs_size
  }

  tags = {
    Name = var.instances[count.index].name
  }
}
