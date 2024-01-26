import logging
import os
import uuid
from abc import ABC, abstractmethod
from functools import singledispatchmethod

import boto3
from tf_pytest.aws import generate_boto3_session
from typing_extensions import override

import pytest

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


class AwsIAMPolicyTester(ABC):
    @abstractmethod
    def __init__(self):
        pass

    @abstractmethod
    def __del__(self):
        pass

    @singledispatchmethod
    @abstractmethod
    def test(self):
        pass


class AwsIAMPolicyTesterS3Write(AwsIAMPolicyTester):
    def __init__(self):
        pass

    def __del__(self):
        pass

    @singledispatchmethod
    @override
    def test(self):
        raise NotImplementedError(f"This {type(self).__name__} does not implement test().")

    @test.register
    def _test_impl(self, iam_role_name: str, bucket_name: str, object_key: str) -> bool:
        try:
            session = generate_boto3_session(iam_role_name)
            s3 = session.client("s3")
            s3.put_object(Bucket=bucket_name, Key=object_key, Body="test")
            s3.delete_object(Bucket=bucket_name, Key=object_key)
            return True
        except Exception as e:
            _logger.error(e)
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
def test_write_object(tfstate_skip_apply, request, iam_role, expect):
    root = tfstate_skip_apply

    aws_s3_bucket = root.module.default.aws_s3_bucket.default
    aws_iam_role = root.aws_iam_role.defaults[iam_role]

    object_key = str(uuid.uuid4())

    tester = AwsIAMPolicyTesterS3Write()

    assert tester.test(aws_iam_role.values["arn"], aws_s3_bucket.values["bucket"], object_key) == expect


class AwsIAMPoliyTesterS3Read(AwsIAMPolicyTester):
    def __init__(self, aws_s3_bucket_name: str, aws_s3_object_key: str):
        _logger.info("__init__()")
        self._aws_s3_bucket_name = aws_s3_bucket_name
        self._aws_s3_object_key = aws_s3_object_key

        client = boto3.client("s3")
        client.put_object(Bucket=self._aws_s3_bucket_name, Key=self._aws_s3_object_key, Body="test")

    def __del__(self):
        _logger.info("__del__()")
        client = boto3.client("s3")
        client.delete_object(Bucket=self._aws_s3_bucket_name, Key=self._aws_s3_object_key)

    @singledispatchmethod
    @override
    def test(self):
        raise NotImplementedError(f"This {type(self).__name__} does not implement test().")

    @test.register
    def _test_impl(self, iam_role_name: str):
        try:
            session = generate_boto3_session(iam_role_name)
            s3 = session.client("s3")
            s3.get_object(Bucket=self._aws_s3_bucket_name, Key=self._aws_s3_object_key)
            return True
        except Exception as e:
            _logger.error(e)
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
def test_read_object(tfstate_skip_apply, request, iam_role, expect):
    root = tfstate_skip_apply

    object_key = str(uuid.uuid4())

    aws_s3_bucket = root.module.default.aws_s3_bucket.default
    aws_iam_role = root.aws_iam_role.defaults[iam_role]

    tester = AwsIAMPoliyTesterS3Read(
        **{
            "aws_s3_bucket_name": aws_s3_bucket.values["bucket"],
            "aws_s3_object_key": object_key,
        }
    )

    assert tester.test(aws_iam_role.values["arn"]) == expect
