variable "cluster_name" {
  type = string
}

variable "task_family" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "email" {
  type = string
}

variable "repo_url" {
  type = string
}

variable "region_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}