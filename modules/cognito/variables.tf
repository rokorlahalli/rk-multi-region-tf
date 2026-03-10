variable "region" {
    type = string
    description = "region for creation of resource"
    default = ""
  
}

variable "user_pool_name" {
    type = string
    description = "Name of Cognito User pool" 
}

variable "user_pool_client" {
    type = string
    description = "Name of Cognito User Pool Client"    
}

variable "tags" {
    type = map(string)
    description = "Tags to apply to resources"
    default = {} 
}