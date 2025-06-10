# S3 Buckets
resource "aws_s3_bucket" "main" {
    for_each = { for bucket in var.buckets : bucket.name => bucket }
    bucket   = each.value.name

    tags = {
        Name = each.value.name
    }
}

# Enable Versioning for S3 Buckets
resource "aws_s3_bucket_versioning" "main" {
    for_each = aws_s3_bucket.main
    bucket   = each.value.id

    versioning_configuration {
        status = try(each.value.versioning_enabled, false) ? "Enabled" : "Suspended"
    }
}

# IAM Policies for S3 Access
resource "aws_iam_policy" "s3_access" {
    for_each    = { for policy in var.policies : policy.name => policy }
    name        = "${each.value.name}-policy"
    description = "Policy for accessing S3 buckets"

    policy = jsonencode({
        Version   = "2012-10-17"
        Statement = [
            for statement in each.value.statements : {
                Effect   = statement.effect
                Action   = statement.actions
                Resource = [
                    for bucket_name in statement.bucket_names :
                    statement.resource_type == "bucket"
                        ? aws_s3_bucket.main[bucket_name].arn
                        : "${aws_s3_bucket.main[bucket_name].arn}/*"
                ]
            }
        ]
    })

    tags = {
        Name = "${each.value.name}-policy"
    }
}

# IAM Users
resource "aws_iam_user" "s3_users" {
    for_each = toset(var.s3_users)
    name     = each.value

    tags = {
        Name = each.value
    }
}

# IAM Access Keys
resource "aws_iam_access_key" "s3_users" {
    for_each = toset(var.s3_users)
    user     = aws_iam_user.s3_users[each.value].name
}

# Attach Policies to Users
resource "aws_iam_user_policy_attachment" "s3_user_policy" {
    for_each = {
        for pair in setproduct(var.s3_users, var.policies) :
        "${pair[0]}-${pair[1].name}" => {
            user       = pair[0]
            policy_arn = aws_iam_policy.s3_access[pair[1].name].arn
        } if contains(try(pair[1].users, []), pair[0])
    }
    user       = each.value.user
    policy_arn = each.value.policy_arn
}