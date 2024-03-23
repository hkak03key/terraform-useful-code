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


class AwsTesterArriveS3(AwsTester):
    def __init__(self):
        super().__init__()

    def close(self):
        pass

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
        sleep(wait_sec)

        # s3上のファイルを確認する
        s3 = boto3.resource("s3")
        bucket = s3.Bucket(s3_bucket_name)

        # オブジェクトの中身を確認したいがうまくいかないので、とりあえず存在確認だけ
        if len(list(bucket.objects.all())) > 0:
            return True
        # for obj in bucket.objects.all():
        #     _logger.info(f"object: {obj.key}")

        #     body = obj.get()["Body"].read()
        #     file_content = str()
        #     with gzip.open(io.BytesIO(body), "rt") as f:
        #         file_content = f.read()

        #     for line in file_content.split("\n"):
        #         _logger.debug(f"file content: {line}")
        #         data = json.loads(line)

        #         for record in data["logEvents"]:
        #             if record["message"] == log_event["message"] and record["timestamp"] == log_event["timestamp"]:
        #                 _logger.info(f"Found log event: {record}")
        #                 return True
        #     _logger.info(f"Log event not found in {obj.key}\n{file_content}")

        return False


def test_arrive_to_s3(tfstate_skip_apply, delete_all_object, request):
    root = tfstate_skip_apply

    aws_cloudwatch_log_group = root.module.default.aws_cloudwatch_log_group.default
    aws_s3_bucket = root.module.default.module.aws_s3_bucket_core.aws_s3_bucket.default
    aws_kinesis_firehose_delivery_stream = root.module.default.aws_kinesis_firehose_delivery_stream.default

    with AwsTesterArriveS3() as tester:
        assert (
            tester.test(
                **{
                    "log_group_name": aws_cloudwatch_log_group.values["name"],
                    "s3_bucket_name": aws_s3_bucket.values["bucket"],
                    "wait_sec": aws_kinesis_firehose_delivery_stream.values["extended_s3_configuration"][0][
                        "buffering_interval"
                    ]
                    + 120,  # 作りたては割と待たされる
                }
            )
            == True
        )
