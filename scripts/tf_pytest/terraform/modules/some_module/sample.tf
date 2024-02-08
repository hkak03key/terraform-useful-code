resource "time_static" "default" {}


resource "time_static" "count" {
  count = 2
}


resource "time_static" "for_each" {
  for_each = toset(["one", "two"])
}


data "http" "default" {
  url = "https://checkpoint-api.hashicorp.com/v1/check/terraform"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}


data "http" "count" {
  count = 2

  url = "https://checkpoint-api.hashicorp.com/v1/check/terraform"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}


data "http" "for_each" {
  for_each = toset(["one", "two"])

  url = "https://checkpoint-api.hashicorp.com/v1/check/terraform"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}
