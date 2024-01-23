import logging
import os

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def test_tfstate_skip_apply(tfstate_skip_apply):
    _logger.info("test_tfstate_skip_apply")


def test_tfstate(tfstate):
    _logger.info("test_tfstate")
