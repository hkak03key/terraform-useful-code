import logging
import os
import uuid

import boto3
from tf_pytest.aws import AwsIAMPolicyTester

import pytest

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


class AwsIAMPolicyTesterKmsUse(AwsIAMPolicyTester):
    def close(self):
        pass

    def test(self, aws_kms_key_key_id: str) -> bool:
        try:
            kms = self._session.client("kms")
            kms.encrypt(KeyId=aws_kms_key_key_id, Plaintext="test")
            return True
        except Exception as e:
            _logger.info(e)
            return False


_params_key_test_kms_use = [
    "iam_role",
    "kms",
    "expect",
]


@pytest.mark.parametrize(
    ",".join(_params_key_test_kms_use),
    [
        tuple([d[k] for k in _params_key_test_kms_use])
        for d in [
            {
                "iam_role": "admin_iam_policy_kms_policy",
                "kms": "default",
                "expect": False,
            },
            {
                "iam_role": "user_no_iam_policy_kms_policy",
                "kms": "default",
                "expect": True,
            },
            {
                "iam_role": "admin_iam_policy_no_kms_policy",
                "kms": "enable_access_with_iam_policy",
                "expect": True,
            },
            {
                "iam_role": "admin_no_iam_policy_kms_policy",
                "kms": "enable_access_as_user_by_admin",
                "expect": True,
            },
        ]
    ],
)
def test_kms_use(tfstate_skip_apply, request, iam_role, kms, expect):
    root = tfstate_skip_apply

    aws_iam_role = root.aws_iam_role.defaults[iam_role]
    aws_kms_key = root.module.defaults[kms].aws_kms_key.default
    aws_kms_alias = root.module.defaults[kms].aws_kms_alias.default

    with AwsIAMPolicyTesterKmsUse(**{"aws_iam_role_arn": aws_iam_role.values["arn"]}) as tester:
        assert tester.test(aws_kms_key.values["key_id"]) == expect
        assert tester.test(aws_kms_alias.values["name"]) == expect


class AwsIAMPolicyTesterKmsAdmin(AwsIAMPolicyTester):
    def close(self):
        pass

    def test(self, aws_kms_key_key_id: str) -> bool:
        try:
            # kms policyを取得し、そのpolicyをputする
            kms = self._session.client("kms")
            kms_policy = kms.get_key_policy(KeyId=aws_kms_key_key_id, PolicyName="default")
            kms.put_key_policy(
                **{
                    "KeyId": aws_kms_key_key_id,
                    "PolicyName": "default",
                    "Policy": kms_policy["Policy"],
                }
            )
            return True
        except Exception as e:
            _logger.info(e)
            return False


_params_key_test_kms_admin = [
    "iam_role",
    "kms",
    "expect",
]


@pytest.mark.parametrize(
    ",".join(_params_key_test_kms_admin),
    [
        tuple([d[k] for k in _params_key_test_kms_admin])
        for d in [
            {
                "iam_role": "admin_no_iam_policy_kms_policy",
                "kms": "default",
                "expect": True,
            },
            {
                "iam_role": "admin_iam_policy_no_kms_policy",
                "kms": "enable_access_with_iam_policy",
                "expect": True,
            },
            {
                "iam_role": "user_no_iam_policy_kms_policy",
                "kms": "default",
                "expect": False,
            },
        ]
    ],
)
def test_kms_admin(tfstate_skip_apply, request, iam_role, kms, expect):
    root = tfstate_skip_apply

    aws_iam_role = root.aws_iam_role.defaults[iam_role]
    aws_kms_key = root.module.defaults[kms].aws_kms_key.default

    with AwsIAMPolicyTesterKmsAdmin(**{"aws_iam_role_arn": aws_iam_role.values["arn"]}) as tester:
        assert tester.test(aws_kms_key.values["key_id"]) == expect
