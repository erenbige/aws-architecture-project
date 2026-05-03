resource "aws_dynamodb_table" "db" {
  name           = "MostOptimizedDB"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}