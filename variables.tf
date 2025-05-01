variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "app_name" {
  description = "The name of the application"
  type        = string
  default     = "mlops"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}