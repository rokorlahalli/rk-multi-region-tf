variable "sns_topic_arn" {
    type = string
    default = "arn:aws:sns:us-east-1:637226132752:Candidate-Verification-Topic"
}

variable "email" {
    type = string
    default = "rohit.korlahalli21@gmail.com" 
}

variable "repo_url" {
    type = string
    default = "https://github.com/rokorlahalli/unleash-assessment"
}