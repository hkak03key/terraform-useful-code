resource "time_static" "default" {}


resource "time_static" "count" {
  count = 2
}


resource "time_static" "for_each" {
  for_each = toset(["one", "two"])
}


module "some_module" {
  source = "./modules/some_module"
}


module "some_module_count" {
  count = 2

  source = "./modules/some_module"
}


module "some_module_for_each" {
  for_each = toset(["one", "two"])

  source = "./modules/some_module"
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
