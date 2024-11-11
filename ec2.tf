resource "aws_instance" "public" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.public_instance_type
  subnet_id              = element(aws_subnet.public[*].id, count.index)
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name              = var.key_name

  # Use template file
  user_data = file("${path.module}/public_user_data.sh")

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-instance-${count.index + 1}"
    Type = "Public"
  })

  # Prevent replacement on user data changes
  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "null_resource" "update_instances" {
  count = var.instance_count

  triggers = {
    script_hash = filemd5("${path.module}/public_user_data.sh")
    instance_id = aws_instance.public[count.index].id
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.root}/${var.key_name}.pem")  # Updated path
    host        = aws_instance.public[count.index].public_ip
    timeout     = "5m"  # Added timeout
    agent       = false # Disable SSH agent
  }

  # Copy the script
  provisioner "file" {
    source      = "public_user_data.sh"
    destination = "/tmp/public_user_data.sh"
  }

  # Execute the script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/public_user_data.sh",
      "sudo bash /tmp/public_user_data.sh",  # Added bash explicitly
      "rm /tmp/public_user_data.sh"
    ]
  }

  depends_on = [aws_instance.public]
}

# Private EC2 Instances
resource "aws_instance" "private" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = local.private_instance_type
  subnet_id              = element(aws_subnet.private[*].id, count.index)
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name              = var.key_name

  user_data = local.private_user_data

  root_block_device {
    volume_size = var.environment == "prod" ? 100 : 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-instance-${count.index + 1}"
    Type = "Private"
  })
}