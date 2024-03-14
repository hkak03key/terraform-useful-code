data "http" "this" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}


data "tls_certificate" "this" {
  url = jsondecode(data.http.this.response_body).jwks_uri
}


resource "aws_iam_openid_connect_provider" "this" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]

  tags = {
    Name = replace(
      join("-", [local.name_prefix]),
      "_", "-"
    )
  }
}
