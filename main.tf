data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "allow_ssh" {
    name = "allow_ssh"
    vpc_id = aws_vpc.valheim.id

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ var.ssh_allowed_inbound ]
    }
}

resource "aws_security_group" "allow_valheim" {
    name = "allow_valheim"
    vpc_id = aws_vpc.valheim.id

    ingress {
        description = "Valheim"
        from_port = 2456
        to_port = 2458
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_outbound" {
    name = "allow_outbound"
    vpc_id = aws_vpc.valheim.id

    egress {
        description = "Allow all outbound"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}


data "template_file" "docker_compose" {
    template = file("${path.module}/templates/docker-compose.yml.tpl")
    vars = {
        name = var.server_name
        world = var.world_name
        password = var.server_password
        timezone = var.timezone
    }
}

resource "aws_key_pair" "host_key" {
    key_name = "host-key"
    public_key = file(var.public_key)
}

resource "aws_instance" "host" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    availability_zone = var.availability_zone
    iam_instance_profile = aws_iam_instance_profile.backup_profile.id
    associate_public_ip_address = true
    vpc_security_group_ids = [
        aws_security_group.allow_ssh.id,
        aws_security_group.allow_valheim.id,
        aws_security_group.allow_outbound.id
    ]
    subnet_id = aws_subnet.valheim_public.id
    key_name = aws_key_pair.host_key.key_name

    tags = {
        Name = var.name
    }
    
    connection {
        host = self.public_ip
        type = "ssh"
        user = "ubuntu"
        private_key = file(var.private_key)
    }

    provisioner "file" {
      content = data.template_file.docker_compose.rendered
      destination = "~/docker-compose.yml"
    }

    provisioner "remote-exec" {
        inline = [
            "mkdir ~/valheim ~/valheim/saves/ ~/valheim/saves/worlds"
        ]
    }

    provisioner "file" {
      source = "${path.module}/worlds/${var.world_name}/"
      destination = "~/valheim/saves/worlds/"
    }

    provisioner "remote-exec" {
      script = "${path.module}/scripts/install-docker.sh"
    }
}

resource "aws_eip" "lb" {
    instance = aws_instance.host.id
    vpc = true
}