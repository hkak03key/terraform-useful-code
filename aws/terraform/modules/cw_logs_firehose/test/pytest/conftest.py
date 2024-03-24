import json
import logging
import os
import sys

import boto3
from tf_pytest import *

import pytest


def _config_root_logger():
    root_logger = logging.getLogger()

    # local用
    stream_handler = logging.StreamHandler(sys.stdout)
    root_logger.addHandler(stream_handler)
    formatter = logging.Formatter("%(asctime)s [%(levelname)s] (%(filename)s | %(funcName)s | %(lineno)s) %(message)s")
    stream_handler.setFormatter(formatter)


_config_root_logger()

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


# FIXME: 関数名
@pytest.fixture(scope="session")
def delete_all_object(init_destroy):
    yield

    _logger.info("delete all object")

    root = init_destroy
    aws_s3_bucket = root.module.default.module.aws_s3_bucket_core.aws_s3_bucket.default

    bucket_name = aws_s3_bucket.values["bucket"]
    _logger.info(f"bucket_name: {bucket_name}")

    put_bucket_policy_for_block_new_object(bucket_name)
    boto3.resource("s3").Bucket(bucket_name).objects.all().delete()
    boto3.resource("s3").Bucket(bucket_name).delete()


def put_bucket_policy_for_block_new_object(s3_bucket_name):
    bucket_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Deny",
                "Principal": "*",
                "Action": "s3:Put*",
                "Resource": f"arn:aws:s3:::{s3_bucket_name}/*",
            }
        ],
    }

    s3 = boto3.client("s3")
    s3.put_bucket_policy(Bucket=s3_bucket_name, Policy=json.dumps(bucket_policy))
