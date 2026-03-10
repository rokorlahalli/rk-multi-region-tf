resource "aws_cognito_user_pool" "my_user_pool" {
  name = var.user_pool_name

  region = var.region

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]

  mfa_configuration = "OFF"

  password_policy {
    minimum_length = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers = true
    require_symbols = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name = "verified_email"
      priority = 1
    }
  }

  schema {
    name = "email"
    attribute_data_type = "String"
    required = true
    mutable = true
  }

  tags = var.tags

}

resource "aws_cognito_user_pool_client" "user_pool_client" {
    name = var.user_pool_client
    user_pool_id = aws_cognito_user_pool.my_user_pool.id

    generate_secret = false

    explicit_auth_flows = [ 
        "ALLOW_USER_PASSWORD_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH"
    ]

    supported_identity_providers = ["COGNITO"]

    prevent_user_existence_errors = "ENABLED"

    allowed_oauth_flows_user_pool_client = false

    access_token_validity = 60
    id_token_validity = 60
    refresh_token_validity = 30

    token_validity_units {
      access_token = "minutes"
      id_token = "minutes"
      refresh_token = "days"
    }
#tags = var.tags 
  
}

