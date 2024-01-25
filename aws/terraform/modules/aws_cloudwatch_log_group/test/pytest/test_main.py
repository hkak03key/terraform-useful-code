import logging
import os
import uuid

import boto3

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


def generate_boto3_session(iam_role_arn, region_name="ap-northeast-1"):
    client = boto3.client("sts")
    account_id = client.get_caller_identity()["Account"]

    response = client.assume_role(RoleArn=iam_role_arn, RoleSessionName=str(uuid.uuid4()))

    session = boto3.session.Session(
        aws_access_key_id=response["Credentials"]["AccessKeyId"],
        aws_secret_access_key=response["Credentials"]["SecretAccessKey"],
        aws_session_token=response["Credentials"]["SessionToken"],
        region_name=region_name,
    )
    return session


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
