variable "buckets" {
    description = "List of S3 buckets to create with their configurations"
    type = list(object({
        name               = string
        versioning_enabled = bool
    }))
    default = []
}

variable "policies" {
    description = "List of IAM policies for S3 access"
    type = list(object({
        name       = string
        statements = list(object({
            effect        = string
            actions       = list(string)
            bucket_names  = list(string)
            resource_type = string # "bucket" or "object"
        }))
        users = optional(list(string), [])
    }))
    default = []
}

variable "s3_users" {
    description = "List of IAM user names to create and attach to S3 policies"
    type        = list(string)
    default     = []
}