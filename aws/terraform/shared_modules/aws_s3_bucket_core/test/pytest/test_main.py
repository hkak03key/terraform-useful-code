import logging
import os
import uuid

import boto3
from tf_pytest.aws import generate_boto3_session

import pytest

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


@pytest.fixture(
    params=[
        {
            "iam_role": "read",
            "result": False,
        },
        {
            "iam_role": "readwrite",
            "result": True,
        },
        {
            "iam_role": "not_attached",
            "result": False,
        },
    ]
)
def generate_params_for_test_write_object(tfstate_skip_apply, request):
    root = tfstate_skip_apply

    object_key = str(uuid.uuid4())

    params = {
        "pattern": request.param,
        "result": request.param["result"],
        "kwargs": {
            "aws_s3_bucket": root.module.default.aws_s3_bucket.default,
            "aws_iam_role": root.aws_iam_role.defaults[request.param["iam_role"]],
            "object_key": object_key,
        },
    }

    yield params

    # 後始末
    client = boto3.client("s3")
    client.delete_object(Bucket=params["kwargs"]["aws_s3_bucket"].values["bucket"], Key=params["kwargs"]["object_key"])


def is_possible_to_write_object(session, bucket_name, object_key):
    try:
        s3 = session.client("s3")
        # put
        s3.put_object(Bucket=bucket_name, Key=object_key, Body="test")
        # delete
        s3.delete_object(Bucket=bucket_name, Key=object_key)
        return True

    except Exception as e:
        _logger.error(e)
        return False


def test_write_object(generate_params_for_test_write_object):
    _logger.info("test_put_log_events")

    params = generate_params_for_test_write_object
    pattern = params["pattern"]

    _logger.info({"pattern": pattern})

    session = generate_boto3_session(params["kwargs"]["aws_iam_role"].values["arn"])

    result = is_possible_to_write_object(
        session, params["kwargs"]["aws_s3_bucket"].values["bucket"], params["kwargs"]["object_key"]
    )

    assert result == params["result"]


@pytest.fixture(
    params=[
        {
            "iam_role": "read",
            "result": True,
        },
        {
            "iam_role": "readwrite",
            "result": True,
        },
        {
            "iam_role": "not_attached",
            "result": False,
        },
    ]
)
def generate_params_for_test_read_object(tfstate_skip_apply, request):
    root = tfstate_skip_apply

    object_key = str(uuid.uuid4())

    params = {
        "pattern": request.param,
        "result": request.param["result"],
        "kwargs": {
            "aws_s3_bucket": root.module.default.aws_s3_bucket.default,
            "aws_iam_role": root.aws_iam_role.defaults[request.param["iam_role"]],
            "object_key": object_key,
        },
    }

    # 準備
    client = boto3.client("s3")
    client.put_object(
        Bucket=params["kwargs"]["aws_s3_bucket"].values["bucket"], Key=params["kwargs"]["object_key"], Body="test"
    )

    yield params

    # 後始末
    client = boto3.client("s3")
    client.delete_object(Bucket=params["kwargs"]["aws_s3_bucket"].values["bucket"], Key=params["kwargs"]["object_key"])


def is_possible_to_read_object(session, bucket_name, object_key):
    try:
        s3 = session.client("s3")
        # read
        s3.get_object(Bucket=bucket_name, Key=object_key)
        return True

    except Exception as e:
        _logger.error(e)
        return False


def test_read_object(generate_params_for_test_read_object):
    _logger.info("test_put_log_events")

    params = generate_params_for_test_read_object
    pattern = params["pattern"]

    _logger.info({"pattern": pattern})

    session = generate_boto3_session(params["kwargs"]["aws_iam_role"].values["arn"])

    result = is_possible_to_read_object(
        session, params["kwargs"]["aws_s3_bucket"].values["bucket"], params["kwargs"]["object_key"]
    )

    assert result == params["result"]
