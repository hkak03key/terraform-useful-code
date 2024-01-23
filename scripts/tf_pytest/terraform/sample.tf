resource "time_static" "default" {}


module "some_module" {
  source = "./modules/some_module"
}


data "http" "default" {
  url = "https://checkpoint-api.hashicorp.com/v1/check/terraform"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}
