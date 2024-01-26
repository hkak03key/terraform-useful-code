import logging
import os
import uuid

import boto3
from tf_pytest.aws import AwsIAMPolicyTester

import pytest

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


class AwsIAMPolicyTesterCloudwatchLogs(AwsIAMPolicyTester):
    def __init__(self, aws_iam_role_arn: str):
        super().__init__(aws_iam_role_arn)

    def close(self):
        pass

    def test(self, log_group_name: str) -> bool:
        client = self._session.client("logs")
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


@pytest.mark.parametrize(
    "iam_role, expect",
    [
        (d["iam_role"], d["expect"])
        for d in [
            {
                "iam_role": "attached",
                "expect": True,
            },
            {
                "iam_role": "not_attached",
                "expect": False,
            },
        ]
    ],
)
def test_put_log_events(tfstate_skip_apply, request, iam_role, expect):
    root = tfstate_skip_apply

    aws_iam_role = root.aws_iam_role.defaults[iam_role]

    aws_cloudwatch_log_group = root.module.default.aws_cloudwatch_log_group.default

    with AwsIAMPolicyTesterCloudwatchLogs(
        **{
            "aws_iam_role_arn": aws_iam_role.values["arn"],
        }
    ) as tester:
        assert tester.test(aws_cloudwatch_log_group.values["name"]) == expect
