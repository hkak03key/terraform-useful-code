import json
import logging
import os
import subprocess
import sys
import time
from abc import ABC, abstractmethod

import pytest
import tfstate as tfstate_module
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

    _apply()
    time.sleep(3)

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
    return _apply()


def _apply():
    cwd = os.environ.get("TF_PYTEST_DIR", "../terraform")

    _logger.info("terraform apply")
    _exec_cmd(["terraform", "apply", "-lock=false", "-auto-approve"], cwd=cwd, print_stdout=True, print_stderr=True)


@pytest.fixture(scope="function", autouse=False)
def tfstate(apply):
    root = tfstate_module.NodeRoot()
    return root


@pytest.fixture(scope="function", autouse=False)
def tfstate_skip_apply(init_destroy):
    root = tfstate_module.NodeRoot()
    return root


if __name__ == "__main__":
    _config_root_logger()
