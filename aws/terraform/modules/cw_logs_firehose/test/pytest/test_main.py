import gzip
import io
import json
import logging
import os
import uuid
from datetime import datetime
from time import sleep

import boto3
from tf_pytest.aws import AwsTester

import pytest

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


class AwsTesterStream(AwsTester):
    def close(self):
        s3 = boto3.resource("s3")
        bucket = s3.Bucket(self.bucket_name)
        bucket.Object(self.object_key).delete()

    def test(self, log_group_name: str, s3_bucket_name: str, wait_sec: int) -> bool:
        logs = boto3.client("logs")
        logs_stream_name = str(uuid.uuid4())

        response = logs.create_log_stream(
            logGroupName=log_group_name,
            logStreamName=logs_stream_name,
        )
        log_event = {
            "timestamp": int(datetime.now().timestamp() * 1000),
            "message": "test",
        }

        response = logs.put_log_events(
            logGroupName=log_group_name,
            logStreamName=logs_stream_name,
            logEvents=[log_event],
        )
        sleep(wait_sec * 1.5)

        # s3上のファイルを確認する
        s3 = boto3.resource("s3")
        bucket = s3.Bucket(s3_bucket_name)
        for obj in bucket.objects.all():
            # .gzファイル以外はスキップ
            if not obj.key.endswith(".gz"):
                continue

            body = obj.get()["Body"].read()
            file_content = str()
            # gzipがなぜか二重になっていることに注意する
            with gzip.open(io.BytesIO(body), "rb") as f1:
                with gzip.open(io.BytesIO(f1.read()), "rt") as f2:
                    file_content = f2.read()

            data = json.loads(file_content)
            for record in data["logEvents"]:
                if record["message"] == log_event["message"] and record["timestamp"] == log_event["timestamp"]:
                    # 後始末用
                    self.bucket_name = s3_bucket_name
                    self.object_key = obj.key
                    return True

        return False


def test_put_log_events(tfstate_skip_apply, request):
    root = tfstate_skip_apply

    aws_cloudwatch_log_group = root.module.default.aws_cloudwatch_log_group.default
    aws_s3_bucket = root.module.default.module.aws_s3_bucket_core.aws_s3_bucket.default
    aws_kinesis_firehose_delivery_stream = root.module.default.aws_kinesis_firehose_delivery_stream.default

    with AwsTesterStream() as tester:
        assert (
            tester.test(
                **{
                    "log_group_name": aws_cloudwatch_log_group.values["name"],
                    "s3_bucket_name": aws_s3_bucket.values["bucket"],
                    "wait_sec": aws_kinesis_firehose_delivery_stream.values["extended_s3_configuration"][0][
                        "buffering_interval"
                    ],
                }
            )
            == True
        )
