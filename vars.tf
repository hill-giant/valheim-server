variable "name" {
    type = string
    default = "valheim"
}

variable "key_pair_name" {
    type = string
    default = "valheim"
}

variable "public_key" {
    type = string
}

variable "private_key" {
    type = string
}

variable "availability_zone" {
    type = string
    default = "us-east-1a"
}

variable "instance_type" {
    type = string
    default = "t3.medium"
}

variable "server_password" {
    type = string
    sensitive = true
}

variable "server_name" {
    type = string
}

variable "world_name" {
    type = string
}

variable "timezone" {
    type = string
}

variable "ssh_allowed_inbound" {
    type = string
}