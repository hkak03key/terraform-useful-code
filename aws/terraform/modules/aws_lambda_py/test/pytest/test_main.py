import logging
import os
import uuid

import boto3
from tf_pytest.aws import AwsIAMPolicyTester

import pytest

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


class AwsIAMPolicyTesterLambdaExec(AwsIAMPolicyTester):
    def close(self):
        pass

    def test(self, lambda_function_name: str) -> bool:
        client = self._session.client("lambda")
        try:
            response = client.invoke(
                FunctionName=lambda_function_name,
                InvocationType="RequestResponse",
                LogType="Tail",
            )
            _logger.debug(response)
            return True
        except Exception as e:
            _logger.info(e)
            return False

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
def test_invoke_lambda(tfstate_skip_apply, request, iam_role, expect):
    root = tfstate_skip_apply

    aws_iam_role = root.aws_iam_role.defaults[iam_role]

    aws_lambda_function = root.module.default.aws_lambda_function.default

    with AwsIAMPolicyTesterLambdaExec(
        **{
            "aws_iam_role_arn": aws_iam_role.values["arn"],
        }
    ) as tester:
        assert tester.test(aws_lambda_function.values["function_name"]) == expect
