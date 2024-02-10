# s3_secure

## 概要
kmsやbucket policyを利用し、強いアクセス制限をかけたs3 bucketを生成するmodule。

## 作成されるもの
- s3 bucket
- SSE
  - AES256かkms
  - kmsの場合、module内でkmsを作成する

## 注意
- resource `aws_s3_bucket_lifecycle_configuration` は1bucketあたり1個しか作れない。
これにより、すべてのbucketに必須である `abort_incomplete_multipart_upload` の設定を本moduleに含めることができていない。
（設定しないとコスト爆発を引き起こす。）
そのため、各呼び出し元にて必ず `abort_incomplete_multipart_upload` の設定をすること。
[terraform document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration#abort_incomplete_multipart_upload)

