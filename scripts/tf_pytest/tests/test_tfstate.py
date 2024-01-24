import logging
import os

from tf_pytest.tfstate import *

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def test_tfstate_node_root(apply):
    root = NodeRoot()
    _logger.debug(root._state)
    _logger.debug(root.time_static.default.values)

    _logger.debug(root.module.some_module._state)

    _logger.debug(root.data.http.default.values["url"])

    _logger.debug(root.time_static.count[0]._state)

    _logger.debug(root.time_static.for_each["one"]._state)

    _logger.debug(root.module.some_module_count[0]._state)

    _logger.debug(root.module.some_module_for_each["one"]._state)


# FIXME: Node単体でのテストを書く
