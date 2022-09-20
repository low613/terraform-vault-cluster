variable "aws_region" {
  type        = string
  description = "The AWS region to use."
  default     = "ap-southeast-2"
}

variable "aws_access_key_id" {
  type        = string
  description = "The AWS access key ID to use."
  sensitive   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "The AWS secret access key to use."
  sensitive   = true
}

variable "domain_name" {
  type        = string
  description = "The domain name"
}

variable "zone_name" {
  type        = string
  description = "The zone name"
}

variable "priv_key_base64" {
  type        = string
  description = "The vault private key"
  sensitive   = true
}

variable "pub_key_base64" {
  type        = string
  description = "The vault public key"
}

variable "ca_base64" {
  type        = string
  description = "The vault ca cert"
}

variable "ssh_pub_key" {
  type        = string
  description = "The ssh public key to authenticate to the cluster"
}
