locals {
    bucket_name = "valheim-backups-${random_pet.this.id}"
}

resource "random_pet" "this" {
    length = 2
}

data "aws_iam_policy_document" "bucket_policy" {
    statement {
        actions = [
            "s3:ListBucket",
        ]
        resources = [
            "arn:aws:s3:::${local.bucket_name}",
        ]
    }
    statement {
        actions = [
            "s3:PutObject",
            "s3:GetObject",
        ]
        resources = [
            "aws:aws:s3:::${local.bucket_name}/*"
        ]
    }
}

resource "aws_iam_role" "backup_access" {
    assume_role_policy = file("./assume-role-policy.json")
    inline_policy {
        name = "backup-bucket-policy"
        policy = data.aws_iam_policy_document.bucket_policy.json
    }
}

resource "aws_iam_instance_profile" "backup_profile" {
    name = "backup_profile"
    role = aws_iam_role.backup_access.name
}

resource "aws_s3_bucket" "backups" {
    bucket = local.bucket_name
    acl = "private"

    tags = {
        Name = "Valheim Backups"
    }
}