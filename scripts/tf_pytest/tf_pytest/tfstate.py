import json
import logging
import os
import re
from abc import ABC, abstractmethod
from collections import UserList

from .utility import exec_cmd as _exec_cmd

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


# =================================================================
# Node
class Node(ABC):
    @abstractmethod
    def __init__(self, address, state):
        self.address = address
        self._state = state

        _logger.debug("creating {}: {}".format(type(self), self))

    def __str__(self):
        return {
            "address": self.address,
        }.__str__()

    def __repr__(self):
        return {
            "address": self.address,
            "state": self._state,
        }.__repr__()


class NodeResourceType(Node):
    def __init__(self, address, state):
        self.resource_type = address.split(".")[-1]
        super().__init__(address, state)

    def __str__(self):
        return {
            "address": self.address,
            "resource_type": self.resource_type,
        }.__str__()

    def __repr__(self):
        return {
            "address": self.address,
            "state": self._state,
            "resource_type": self.resource_type,
        }.__repr__()


# =================================================================
# NodeResourceType
class NodeResourceTypeResource(NodeResourceType):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))
        _logger.debug(self._state["resources"])

        resources = [resource for resource in self._state["resources"] if resource["name"] == name]
        if len(resources) == 0:
            raise AttributeError("{} is not found.\nclass: {}, current address: {}".format(target_addr, type(self), self.address))

        if not "index" in resources[0].keys():
            return NodeInstanceResource(target_addr, resources[0], self.resource_type)

        else:
            node_list = NodeListInstanceResource(
                [
                    NodeInstanceResource(
                        (
                            target_addr + "[{}]".format(r["index"])
                            if type(r["index"]) == int
                            else target_addr + '["{}"]'.format(r["index"])
                        ),
                        r,
                        self.resource_type,
                    )
                    for r in resources
                ]
            )
            return node_list

        raise AttributeError("{} is not found.\nclass: {}, current address: {}".format(target_addr, type(self), self.address))


class NodeResourceTypeData(NodeResourceTypeResource):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        resources = [resource for resource in self._state["resources"] if resource["name"] == name]

        if len(resources) == 0:
            raise AttributeError("{} is not found.\nclass: {}, current address: {}".format(target_addr, type(self), self.address))

        if not "index" in resources[0].keys():
            return NodeInstanceData(target_addr, resources[0], self.resource_type)

        else:
            node_list = NodeListInstanceData(
                [
                    NodeInstanceData(
                        (
                            target_addr + "[{}]".format(r["index"])
                            if type(r["index"]) == int
                            else target_addr + '["{}"]'.format(r["index"])
                        ),
                        r,
                        self.resource_type,
                    )
                    for r in resources
                ]
            )
            return node_list

        raise AttributeError("{} is not found.\nclass: {}, current address: {}".format(target_addr, type(self), self.address))


# =================================================================
# NodeCategory
class NodeCategory(Node):
    def __init__(self, address, state):
        self.category = address.split(".")[-1]
        super().__init__(address, state)

    def __str__(self):
        return {
            "address": self.address,
            "category": self.category,
        }.__str__()

    def __repr__(self):
        return {
            "address": self.address,
            "state": self._state,
            "category": self.category,
        }.__repr__()


class NodeCategoryData(NodeCategory):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        new_state = {"resources": [resource for resource in self._state["resources"] if resource["type"] == name]}
        if len(new_state["resources"]) == 0:
            raise AttributeError("{} is not found.\nclass: {}, current address: {}".format(target_addr, type(self), self.address))

        return NodeResourceTypeData(target_addr, new_state)


class NodeCategoryModule(NodeCategory):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        modules = [
            child_module
            for child_module in self._state["child_modules"]
            if child_module["address"].startswith(target_addr)
        ]

        # check for_each/count or not
        is_single = all([re.match(r"^\[(.+)\]", module["address"].removeprefix(target_addr)) is None for module in modules])

        if len(modules) == 0:
            raise AttributeError("{} is not found.\nclass: {}, current address: {}".format(target_addr, type(self), self.address))

        if is_single:
            return NodeInstanceModule(target_addr, modules[0], self.category)

        else:
            node_list = NodeListInstanceModule([NodeInstanceModule(m["address"], m, self.category) for m in modules])
            return node_list

        raise AttributeError("{} is not found.\nclass: {}, current address: {}".format(target_addr, type(self), self.address))


# =================================================================
# NodeInstance
class NodeInstance(Node):
    def __init__(self, address, state, resource_type):
        self.resource_type = resource_type
        super().__init__(address, state)

    def __str__(self):
        return {
            "address": self.address,
            "resource_type": self.resource_type,
        }.__str__()

    def __repr__(self):
        return {
            "address": self.address,
            "state": self._state,
            "resource_type": self.resource_type,
        }.__repr__()


class NodeInstanceResource(NodeInstance):
    def __init__(self, address, state, resource_type):
        super().__init__(address, state, resource_type)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))

        if name in self._state.keys():
            return self._state[name]


class NodeInstanceData(NodeInstance):
    def __init__(self, address, state, resource_type):
        super().__init__(address, state, resource_type)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))

        if name in self._state.keys():
            return self._state[name]


class NodeInstanceModule(NodeInstance):
    def __init__(self, address, state, resource_type):
        super().__init__(address, state, resource_type)

    def __getattr__(self, name):
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        if name == "module":
            return NodeCategoryModule(target_addr, {"child_modules": self._state["child_modules"]})

        if name == "data":
            return NodeCategoryData(
                target_addr,
                {"resources": [resource for resource in self._state["resources"] if resource["mode"] == "data"]},
            )

        new_state = {"resources": [resource for resource in self._state["resources"] if resource["type"] == name]}
        if len(new_state["resources"]) == 0:
            raise AttributeError("{} is not found.\nclass: {}, current address: {}".format(target_addr, type(self), self.address))

        return NodeResourceTypeResource(target_addr, new_state)


class NodeInsanceModuleRoot(NodeInstanceModule):
    def __init__(self):
        cwd = os.environ.get("TF_PYTEST_DIR", "../terraform")
        state = json.loads(_exec_cmd(["terraform", "show", "-json"], cwd=cwd, print_stderr=True).stdout.decode("utf8"))

        super().__init__("", state["values"]["root_module"], "module")


def NodeRoot() -> NodeInsanceModuleRoot:
    return NodeInsanceModuleRoot()


# =================================================================
# NodeList
# MEMO: for_eachはUserListではなくUserDictを継承するべきかもしれない
class NodeList(UserList):
    def __init__(self, initlist=None):
        super().__init__(initlist)

        # check type
        for node in self.data:
            if not isinstance(node, Node):
                raise ValueError("node must be NodeInstance")

    def __iter__(self):
        return self.data

    def map(self, f):
        return list(map(f, self.data))

    def __getitem__(self, index):
        for node in self.data:
            if node._state["index"] == index:
                return node

        raise IndexError("index {} is not found".format(index))


class NodeListInstanceResource(NodeList):
    def __init__(self, initlist=None):
        super().__init__(initlist)


class NodeListInstanceData(NodeList):
    def __init__(self, initlist=None):
        super().__init__(initlist)


class NodeListInstanceModule(NodeList):
    def __init__(self, initlist=None):
        super().__init__(initlist)

    def __getitem__(self, index):
        _logger.debug("index: {}".format(index))
        for node in self.data:
            node_index = re.match(r".*\[(.+)\]$", node.address).group(1)

            if type(index) == int and node_index == str(index):
                return node

            if type(index) == str and node_index == f'"{index}"':
                return node

        raise IndexError("index {} is not found".format(index))
