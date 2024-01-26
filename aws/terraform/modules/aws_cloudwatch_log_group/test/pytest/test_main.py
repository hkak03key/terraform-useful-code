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
            "iam_role": "attached",
            "result": True,
        },
        {
            "iam_role": "not_attached",
            "result": False,
        },
    ]
)
def generate_params(tfstate_skip_apply, request):
    root = tfstate_skip_apply

    params = {
        "pattern": request.param,
        "result": request.param["result"],
        "kwargs": {
            "aws_cloudwatch_log_group": root.module.default.aws_cloudwatch_log_group.default,
            "aws_iam_role": root.aws_iam_role.defaults[request.param["iam_role"]],
        },
    }

    yield params


def is_possible_to_put_log_events(session, log_group_name):
    client = session.client("logs")
    logs_stream_name = str(uuid.uuid4())

    try:
        response = client.create_log_stream(
            logGroupName=log_group_name,
            logStreamName=logs_stream_name,
        )

        response = client.put_log_events(
            logGroupName=log_group_name,
            logStreamName=logs_stream_name,
            logEvents=[
                {
                    "timestamp": 0,
                    "message": "test",
                },
            ],
        )
        return True

    except Exception as e:
        _logger.info(e)
        return False


def test_put_log_events(generate_params):
    _logger.info("test_put_log_events")
    _logger.info({"pattern": generate_params["pattern"]})

    params = generate_params

    session = generate_boto3_session(params["kwargs"]["aws_iam_role"].values["arn"])

    result = is_possible_to_put_log_events(session, params["kwargs"]["aws_cloudwatch_log_group"].values["name"])

    assert result == params["result"]
