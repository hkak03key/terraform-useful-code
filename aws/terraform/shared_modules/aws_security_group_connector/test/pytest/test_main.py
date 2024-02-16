import logging
import os
import time
import uuid

import boto3
from tf_pytest.aws import AwsTester

import pytest

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


class AwsTesterNetworkInsights(AwsTester):
    def __init__(self, network_insights_path_id: str):
        self.network_insights_path_id = network_insights_path_id
        super().__init__()

    def close(self):
        client = boto3.client("ec2")

        for page in client.get_paginator("describe_network_insights_analyses").paginate(
            NetworkInsightsPathId=self.network_insights_path_id
        ):
            for analysis in page["NetworkInsightsAnalyses"]:
                response = client.delete_network_insights_analysis(
                    NetworkInsightsAnalysisId=analysis["NetworkInsightsAnalysisId"]
                )
                _logger.info(response)

    def test(self) -> bool:
        client = boto3.client("ec2")
        response = client.start_network_insights_analysis(NetworkInsightsPathId=self.network_insights_path_id)
        _logger.info(response)

        network_insights_analysis_id = response["NetworkInsightsAnalysis"]["NetworkInsightsAnalysisId"]

        while 1:
            response = client.describe_network_insights_analyses(
                NetworkInsightsAnalysisIds=[network_insights_analysis_id]
            )
            _logger.info(response)
            status = response["NetworkInsightsAnalyses"][0]["Status"]

            if status == "succeeded":
                return response["NetworkInsightsAnalyses"][0]["NetworkPathFound"]
            if status == "failed":
                raise Exception(
                    "NetworkInsightsAnalysis failed: " + response["NetworkInsightsAnalyses"][0]["StatusMessage"]
                )

            if status == "running":
                time.sleep(5)
                continue
            else:
                raise Exception("Unknown status")


_params_key_test_network_insights = [
    "insights_path",
    "expect",
]


@pytest.mark.parametrize(
    ",".join(_params_key_test_network_insights),
    [
        tuple([d[k] for k in _params_key_test_network_insights])
        for d in [
            {
                "insights_path": "from_no_attached_to_ingress",
                "expect": False,
            },
            {
                "insights_path": "from_egress_to_ingress",
                "expect": True,
            },
        ]
    ],
)
def test_network_insights(tfstate_skip_apply, insights_path, expect):
    root = tfstate_skip_apply

    aws_ec2_network_insights_path = root.aws_ec2_network_insights_path.defaults[insights_path]

    with AwsTesterNetworkInsights(
        **{
            "network_insights_path_id": aws_ec2_network_insights_path.values["id"],
        }
    ) as tester:
        assert tester.test() == expect
