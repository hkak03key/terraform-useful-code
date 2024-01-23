import json
import logging
import os
import subprocess
import sys
from abc import ABC, abstractmethod

import pytest
from utility import exec_cmd as _exec_cmd


def _config_root_logger():
    root_logger = logging.getLogger()

    # local用
    stream_handler = logging.StreamHandler(sys.stdout)
    root_logger.addHandler(stream_handler)
    formatter = logging.Formatter("%(asctime)s [%(levelname)s] (%(filename)s | %(funcName)s | %(lineno)s) %(message)s")
    stream_handler.setFormatter(formatter)


# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


@pytest.fixture(scope="session")
def init_destroy():
    yield from _init_destroy()


def _init_destroy():
    cwd = os.environ.get("TF_PYTEST_DIR", "../terraform")

    _logger.info("terraform init")
    _exec_cmd(["terraform", "init"], cwd=cwd, print_stdout=True, print_stderr=True)

    yield

    if os.environ.get("TF_PYTEST_DESTROY", "true").lower() == "false":
        _logger.info("terraform destroy skip")
        return

    _exec_cmd(
        ["terraform", "apply", "-lock=false", "-destroy", "-auto-approve"],
        cwd=cwd,
        print_stdout=True,
        print_stderr=True,
    )

    _logger.info("terraform destroy")


@pytest.fixture(scope="function", autouse=False)
def apply(init_destroy):
    cwd = os.environ.get("TF_PYTEST_DIR", "../terraform")

    _logger.info("terraform apply")
    _exec_cmd(["terraform", "apply", "-lock=false", "-auto-approve"], cwd=cwd, print_stdout=True, print_stderr=True)


if __name__ == "__main__":
    _config_root_logger()
