variable "dynamodb_table_name" {
   type = string
   description = "table name"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}