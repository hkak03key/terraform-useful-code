import logging
import os

from tf_pytest.tfstate import *

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def test_tfstate_node_root(init_destroy):
    root = NodeRoot()


def test_tfstate_node_category_resource(init_destroy):
    root = NodeRoot()
    _logger.debug(root.time_static)


def test_tfstate_node_category_data(init_destroy):
    root = NodeRoot()
    _logger.debug(root.data)
    _logger.debug(root.data.http)
    _logger.debug(root.data.http.default)
    _logger.info(root.data.http.default.values["url"])


def test_tfstate_node_category_module(init_destroy):
    root = NodeRoot()
    _logger.debug(root.module)


def test_tfstate_node_instance_resource(init_destroy):
    root = NodeRoot()
    _logger.debug(root.time_static.default)
    _logger.info(root.time_static.default.values["id"])


def test_tfstate_node_instance_data(init_destroy):
    root = NodeRoot()
    _logger.debug(root.data.http.default)
    _logger.info(root.data.http.default.values["url"])


def test_tfstate_nodelist_resource_count(init_destroy):
    root = NodeRoot()
    _logger.debug(root.time_static.count)
    _logger.debug(root.time_static.count[0])
    _logger.info(root.time_static.count.map(lambda r: r.values["id"]))


def test_tfstate_nodelist_resource_for_each(init_destroy):
    root = NodeRoot()
    _logger.debug(root.time_static.for_each)
    _logger.debug(root.time_static.for_each["one"])
    _logger.info(root.time_static.for_each.map(lambda r: r.values["id"]))


def test_tfstate_nodelist_data_count(init_destroy):
    root = NodeRoot()
    _logger.debug(root.data.http.count)
    _logger.debug(root.data.http.count[0])
    _logger.info(root.data.http.count[0].values["url"])
    _logger.info(root.data.http.count.map(lambda r: r.values["url"]))


def test_tfstate_nodelist_data_for_each(init_destroy):
    root = NodeRoot()
    _logger.debug(root.data.http.for_each)
    _logger.debug(root.data.http.for_each["one"])
    _logger.info(root.data.http.for_each["one"].values["url"])
    _logger.info(root.data.http.for_each.map(lambda r: r.values["url"]))


def test_tfstate_nodelist_module_count(init_destroy):
    root = NodeRoot()
    _logger.debug(root.module.some_module_count)
    _logger.debug(root.module.some_module_count[0])
    _logger.info(root.module.some_module_count[0].time_static.default.values["id"])
    _logger.info(root.module.some_module_count.map(lambda m: m.time_static.default.values["id"]))


def test_tfstate_nodelist_module_for_each(init_destroy):
    root = NodeRoot()
    _logger.debug(root.module.some_module_for_each)
    _logger.debug(root.module.some_module_for_each["one"])
    _logger.info(root.module.some_module_for_each["one"].time_static.default.values["id"])
    _logger.info(root.module.some_module_for_each.map(lambda m: m.time_static.default.values["id"]))


def test_tfstate_multiple_nodelist_count(init_destroy):
    root = NodeRoot()
    _logger.info(
        sum(
            root.module.some_module_count.map(
                lambda m: m.time_static.count.map(
                    lambda r: r.values["id"]
                )
            ),
            []
        )
    )

def test_tfstate_multiple_nodelist_for_each(init_destroy):
    root = NodeRoot()
    _logger.info(
        sum(
            root.module.some_module_for_each.map(
                lambda m: m.time_static.for_each.map(
                    lambda r: r.values["id"]
                )
            ),
            []
        )
    )
