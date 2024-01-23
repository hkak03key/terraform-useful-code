import logging
import os
import subprocess
import sys

import pytest


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


def _exec_cmd(cmd, cwd, print_stdout=False, print_stderr=False):
    _logger.info("exec_cmd: {}...".format(" ".join(cmd)))
    proc = subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if print_stdout:
        print(proc.stdout.decode("utf8"))
    if print_stderr:
        print(proc.stderr.decode("utf8"))

    proc.check_returncode()
    return proc


if __name__ == "__main__":
    _config_root_logger()
