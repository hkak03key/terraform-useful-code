import logging
import os
import uuid

import boto3
from tf_pytest.aws import AwsIAMPolicyTester

import pytest

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


class AwsIAMPolicyTesterS3Write(AwsIAMPolicyTester):
    def close(self):
        pass

    def test(self, bucket_name: str, object_key: str) -> bool:
        try:
            s3 = self._session.client("s3")
            s3.put_object(Bucket=bucket_name, Key=object_key, Body="test")
            s3.delete_object(Bucket=bucket_name, Key=object_key)
            return True
        except Exception as e:
            _logger.info(e)
            return False


_params_key_test_s3_write_object = [
    "iam_role",
    "expect",
]


@pytest.mark.parametrize(
    ",".join(_params_key_test_s3_write_object),
    [
        tuple([d[k] for k in _params_key_test_s3_write_object])
        for d in [
            {
                "iam_role": "read",
                "expect": False,
            },
            {
                "iam_role": "readwrite",
                "expect": True,
            },
            {
                "iam_role": "not_attached",
                "expect": False,
            },
            {
                "iam_role": "external",
                "expect": False,
            },
        ]
    ],
)
def test_s3_write_object(tfstate_skip_apply, delete_all_object, request, iam_role, expect):
    root = tfstate_skip_apply

    aws_iam_role = root.aws_iam_role.defaults[iam_role]
    aws_s3_bucket = root.module.default.module.aws_s3_bucket_secure.module.aws_s3_bucket_core.aws_s3_bucket.default

    object_key = str(uuid.uuid4())

    with AwsIAMPolicyTesterS3Write(**{"aws_iam_role_arn": aws_iam_role.values["arn"]}) as tester:
        assert tester.test(aws_s3_bucket.values["bucket"], object_key) == expect


class AwsIAMPolicyTesterS3Read(AwsIAMPolicyTester):
    def __init__(self, aws_iam_role_arn: str, aws_s3_bucket_name: str, aws_s3_object_key: str):
        super().__init__(aws_iam_role_arn)

        self._aws_s3_bucket_name = aws_s3_bucket_name
        self._aws_s3_object_key = aws_s3_object_key

        client = boto3.client("s3")

        _logger.info(f"create object: s3://{self._aws_s3_bucket_name}/{self._aws_s3_object_key}")
        client.put_object(Bucket=self._aws_s3_bucket_name, Key=self._aws_s3_object_key, Body="test")

    def close(self):
        client = boto3.client("s3")

        _logger.info(f"delete object: s3://{self._aws_s3_bucket_name}/{self._aws_s3_object_key}")
        client.delete_object(Bucket=self._aws_s3_bucket_name, Key=self._aws_s3_object_key)

    def test(self) -> bool:
        try:
            s3 = self._session.client("s3")
            s3.get_object(Bucket=self._aws_s3_bucket_name, Key=self._aws_s3_object_key)
            return True
        except Exception as e:
            _logger.info(e)
            return False


_params_key_test_s3_read_object = [
    "iam_role",
    "expect",
]


@pytest.mark.parametrize(
    ",".join(_params_key_test_s3_read_object),
    [
        tuple([d[k] for k in _params_key_test_s3_read_object])
        for d in [
            {
                "iam_role": "read",
                "expect": True,
            },
            {
                "iam_role": "readwrite",
                "expect": True,
            },
            {
                "iam_role": "not_attached",
                "expect": False,
            },
            {
                "iam_role": "external",
                "expect": False,
            },
        ]
    ],
)
def test_s3_read_object(tfstate_skip_apply, delete_all_object, request, iam_role, expect):
    root = tfstate_skip_apply

    aws_iam_role = root.aws_iam_role.defaults[iam_role]
    aws_s3_bucket = root.module.default.module.aws_s3_bucket_secure.module.aws_s3_bucket_core.aws_s3_bucket.default

    object_key = str(uuid.uuid4())

    with AwsIAMPolicyTesterS3Read(
        **{
            "aws_iam_role_arn": aws_iam_role.values["arn"],
            "aws_s3_bucket_name": aws_s3_bucket.values["bucket"],
            "aws_s3_object_key": object_key,
        }
    ) as tester:
        assert tester.test() == expect
