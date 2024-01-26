import logging
import os
import uuid
from functools import singledispatchmethod

import boto3
from tf_pytest.aws import AwsIAMPolicyTester
from typing_extensions import override

import pytest

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


@pytest.fixture(scope="session")
def delete_all_object(init_destroy):
    yield

    _logger.info("delete all object")

    root = init_destroy
    aws_s3_bucket = root.module.default.aws_s3_bucket.default

    bucket_name = aws_s3_bucket.values["bucket"]
    s3 = boto3.resource("s3").Bucket(bucket_name).objects.all().delete()


class AwsIAMPolicyTesterS3Write(AwsIAMPolicyTester):
    def __init__(self, aws_iam_role_arn: str):
        super().__init__(aws_iam_role_arn)

    def __del__(self):
        pass

    @singledispatchmethod
    @override
    def test(self):
        raise NotImplementedError(f"This {type(self).__name__} does not implement test().")

    @test.register
    def _test_impl(self, bucket_name: str, object_key: str) -> bool:
        try:
            s3 = self._session.client("s3")
            s3.put_object(Bucket=bucket_name, Key=object_key, Body="test")
            s3.delete_object(Bucket=bucket_name, Key=object_key)
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
        ]
    ],
)
def test_write_object(tfstate_skip_apply, delete_all_object, request, iam_role, expect):
    root = tfstate_skip_apply

    aws_s3_bucket = root.module.default.aws_s3_bucket.default
    aws_iam_role = root.aws_iam_role.defaults[iam_role]

    object_key = str(uuid.uuid4())

    tester = AwsIAMPolicyTesterS3Write(**{"aws_iam_role_arn": aws_iam_role.values["arn"]})

    assert tester.test(aws_s3_bucket.values["bucket"], object_key) == expect


class AwsIAMPoliyTesterS3Read(AwsIAMPolicyTester):
    def __init__(self, aws_iam_role_arn: str, aws_s3_bucket_name: str, aws_s3_object_key: str):
        super().__init__(aws_iam_role_arn)

        self._aws_s3_bucket_name = aws_s3_bucket_name
        self._aws_s3_object_key = aws_s3_object_key

        client = boto3.client("s3")
        client.put_object(Bucket=self._aws_s3_bucket_name, Key=self._aws_s3_object_key, Body="test")

    def __del__(self):
        client = boto3.client("s3")
        client.delete_object(Bucket=self._aws_s3_bucket_name, Key=self._aws_s3_object_key)

    def test(self):
        try:
            s3 = self._session.client("s3")
            s3.get_object(Bucket=self._aws_s3_bucket_name, Key=self._aws_s3_object_key)
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
        ]
    ],
)
def test_read_object(tfstate_skip_apply, delete_all_object, request, iam_role, expect):
    root = tfstate_skip_apply

    object_key = str(uuid.uuid4())

    aws_s3_bucket = root.module.default.aws_s3_bucket.default
    aws_iam_role = root.aws_iam_role.defaults[iam_role]

    tester = AwsIAMPoliyTesterS3Read(
        **{
            "aws_iam_role_arn": aws_iam_role.values["arn"],
            "aws_s3_bucket_name": aws_s3_bucket.values["bucket"],
            "aws_s3_object_key": object_key,
        }
    )

    assert tester.test() == expect
