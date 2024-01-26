import os
import uuid

import boto3


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
