import logging
import os

from tf_pytest.tfstate import *

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def test_tfstate_node_root(apply):
    root = NodeRoot()
    _logger.debug(root.state)
    _logger.debug(root.time_static)
    _logger.debug(root.time_static.default.values)

    _logger.debug(root.module.some_module.state)

    _logger.debug(root.data.http.default.values["url"])


# FIXME: Node単体でのテストを書く
