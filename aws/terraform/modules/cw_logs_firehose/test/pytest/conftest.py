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


@pytest.fixture(scope="session")
def delete_all_object(init_destroy):
    yield

    _logger.info("delete all object")

    root = init_destroy
    aws_s3_bucket = root.module.default.module.aws_s3_bucket_core.aws_s3_bucket.default

    bucket_name = aws_s3_bucket.values["bucket"]
    s3 = boto3.resource("s3").Bucket(bucket_name).objects.all().delete()
