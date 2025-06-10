output "bucket_arns" {
    description = "Map of bucket names to their ARNs"
    value       = { for k, v in aws_s3_bucket.main : k => v.arn }
}

output "bucket_names" {
    description = "Map of bucket names to their IDs"
    value       = { for k, v in aws_s3_bucket.main : k => v.id }
}

output "iam_user_names" {
    description = "List of IAM user names created"
    value       = [for user in aws_iam_user.s3_users : user.name]
}

output "policy_arns" {
    description = "Map of policy names to their ARNs"
    value       = { for k, v in aws_iam_policy.s3_access : k => v.arn }
}

output "access_keys" {
    description = "Map of IAM user names to their access key IDs and secret access keys"
    value       = {
        for user in var.s3_users : user => {
            access_key_id     = aws_iam_access_key.s3_users[user].id
            secret_access_key = aws_iam_access_key.s3_users[user].secret
        }
    }
    sensitive = true
}