resource "aws_dynamodb_table" "dynamo_table" {
  name         = "${var.table_name}"
  billing_mode = "${var.billing_mode}"
  hash_key     = "${var.hash_key_attr}"

  # Client email for account purposes
  attribute {
    name = "${var.hash_key_attr}"
    type = "${var.hash_key_attr_type}"
  }

  # This sets up DB table backup for up to 35 days into the past
  point_in_time_recovery {
    enabled = "${var.recovery_enabled}"
  }

  # The only attributes you need to specify are the hash key and, optionally,
  # the range (read sort) key. All other attributes are stored as part of each 
  # document (or item) you store in the table. Ergo the below attributes will be 
  # added at upon the creation of new items.

  #   attribute {
  #     name = "Name"
  #     type = "S"
  #   }

  #   # Gmail necessary to support Process Messages with Youtube Live
  #   attribute {
  #     name = "Gmail"
  #     type = "S"
  #   }

  #   # Twilio Number receiving number associated with this client
  #   attribute {
  #     name = "ReceivingNumber"
  #     type = "N"
  #   }

  #   # This is a JSON document but it is stored as (B)inary data
  #   attribute {
  #     name = "Credentials"
  #     type = "B"
  #   }
}
