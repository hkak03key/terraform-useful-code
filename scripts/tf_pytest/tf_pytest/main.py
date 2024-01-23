import logging
import os
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
logger = logging.getLogger(__name__)
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


@pytest.fixture(scope="session")
def init_destroy():
    yield from _init_destroy()


def _init_destroy():
    logger.info("terraform init")

    yield

    if os.environ.get("DESTROY", "true").lower() == "false":
        logger.info("terraform destroy skip")
        return

    logger.info("terraform destroy")


if __name__ == "__main__":
    _config_root_logger()
