variable "dispatcher_zip_file" {
  type = string
}

variable "dispatcher_function_name" {
  type = string
}

variable "dispatcher_handler" {
  type = string
}

variable "dispatcher_runtime" {
  type = string
}

variable "cluster_arn" {
  type = string
}

variable "task_definition_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}