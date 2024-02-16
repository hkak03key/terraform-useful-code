import logging
import os
import uuid
from abc import ABC, abstractmethod

import boto3

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def generate_boto3_session(iam_role_arn, region_name=None):
    _region_name = region_name if region_name else os.environ.get("AWS_REGION", os.environ.get("AWS_DEFAULT_REGION"))
    if not _region_name:
        raise ValueError("region_name is required, or set AWS_REGION or AWS_DEFAULT_REGION environment variable.")

    client = boto3.client("sts")
    account_id = client.get_caller_identity()["Account"]

    response = client.assume_role(RoleArn=iam_role_arn, RoleSessionName=str(uuid.uuid4()))

    session = boto3.session.Session(
        aws_access_key_id=response["Credentials"]["AccessKeyId"],
        aws_secret_access_key=response["Credentials"]["SecretAccessKey"],
        aws_session_token=response["Credentials"]["SessionToken"],
        region_name=_region_name,
    )
    return session


class AwsTester(ABC):
    def __init__(self):
        super().__init__()

    def __enter__(self):
        return self

    @abstractmethod
    def close(self):
        pass

    def __exit__(self, exc_type, exc_value, traceback):
        self.close()

    @abstractmethod
    def test(self):
        pass


class AwsIAMPolicyTester(AwsTester):
    def __init__(self, aws_iam_role_arn: str):
        self._session = generate_boto3_session(aws_iam_role_arn)
        super().__init__()

    @abstractmethod
    def close(self):
        pass

    @abstractmethod
    def test(self):
        pass
