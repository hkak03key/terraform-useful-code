import logging
import os
import sys

from some_module import fetch_page


def _config_root_logger():
    root_logger = logging.getLogger()

    # local用
    stream_handler = logging.StreamHandler(sys.stdout)
    root_logger.addHandler(stream_handler)
    formatter = logging.Formatter("%(asctime)s [%(levelname)s] (%(filename)s | %(funcName)s | %(lineno)s) %(message)s")
    stream_handler.setFormatter(formatter)


if os.environ.get("AWS_LAMBDA_FUNCTION_NAME") is None:
    _config_root_logger()


# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def some_proc(url):
    ret = fetch_page(url)
    _logger.debug(f"fetch_page: {ret}")

    return ret


def lambda_handler(event, context):
    url = event.get("url", "https://checkpoint-api.hashicorp.com/v1/check/terraform")

    return some_proc(url)


# `poetry run python script/main.py`
if __name__ == "__main__":
    print(lambda_handler({}, {}))
