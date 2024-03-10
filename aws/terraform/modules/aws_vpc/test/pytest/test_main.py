import logging
import os
import uuid

import boto3

import pytest

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def test_apply_and_destroy(tfstate):
    root = tfstate
