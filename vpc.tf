resource "aws_vpc" "valheim" {
    cidr_block = "10.0.0.0/24"

    tags = {
        Name = "Valheim"
    }
}

resource "aws_internet_gateway" "valheim" {
    vpc_id = aws_vpc.valheim.id

    tags = {
        Name = "Valheim"
    }
}

resource "aws_subnet" "valheim_public" {
    vpc_id = "${aws_vpc.valheim.id}"
    cidr_block = "10.0.0.0/25"
    availability_zone = var.availability_zone

    tags = {
        Name = "Valheim Public Subnet"
    }
}

resource "aws_route_table" "valheim_public" {
    vpc_id = aws_vpc.valheim.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.valheim.id
    }
}

resource "aws_route_table_association" "valheim_public" {
    subnet_id = aws_subnet.valheim_public.id
    route_table_id = aws_route_table.valheim_public.id
}

resource "aws_subnet" "valheim_private" {
    vpc_id = aws_vpc.valheim.id
    cidr_block = "10.0.0.128/25"
    availability_zone = var.availability_zone

    tags = {
        Name = "Valheim Private Subnet"
    }
}