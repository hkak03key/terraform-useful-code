import json
import logging
import os
from abc import ABC, abstractmethod

from .utility import exec_cmd as _exec_cmd

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


class Node(ABC):
    @abstractmethod
    def __init__(self, address, state):
        self.address = address
        self._state = state

    def __str__(self):
        return {
            "address": self.address,
            "state": self._state,
        }.__str__()

    def __repr__(self):
        return {
            "address": self.address,
            "state": self._state,
        }.__repr__()


class NodeResources(Node):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        _logger.debug("self._state: {}".format(self._state))

        new_state = [resource for resource in self._state["resources"] if resource["name"] == name]
        if len(new_state) == 1:
            return NodeResource(target_addr, new_state[0])

        if len(new_state) >= 2:
            return NodeResource(target_addr, new_state)

        raise AttributeError("{} is not found".format(target_addr))


class NodeDatas(Node):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        _logger.debug("self._state: {}".format(self._state))

        new_state = {"resources": [resource for resource in self._state["resources"] if resource["type"] == name]}
        _logger.debug("new_state: {}".format(new_state))
        if len(new_state["resources"]) == 0:
            raise AttributeError("{} is not found".format(target_addr))

        return NodeResources(target_addr, new_state)


class NodeResource(Node):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))

        if name in self._state.keys():
            return self._state[name]

    def __getitem__(self, index):
        _logger.debug("index: {}".format(index))

        target_addr = (
            (self.address + "[" + str(index) + "]").removeprefix(".")
            if type(index) is int
            else (self.address + '["' + index + '"]').removeprefix(".")
        )
        _logger.debug("target_addr: {}".format(target_addr))

        _logger.debug("self._state: {}".format(self._state))

        for resource in self._state:
            if resource["index"] == index:
                return NodeResource(target_addr, resource)

        raise AttributeError("{} is not found".format(target_addr))


class NodeModules(Node):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        _logger.debug("self._state: {}".format(self._state))

        new_state = [
            child_module
            for child_module in self._state["child_modules"]
            if child_module["address"].startswith(target_addr)
        ]
        if len(new_state) == 1:
            return NodeModule(target_addr, new_state[0])

        if len(new_state) >= 2:
            return NodeModule(target_addr, new_state)

        raise AttributeError("{} is not found".format(target_addr))


class NodeModule(Node):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        _logger.debug("self._state: {}".format(self._state))

        if name == "module":
            return NodeModules(target_addr, {"child_modules": self._state["child_modules"]})

        if name == "data":
            return NodeDatas(
                target_addr,
                {"resources": [resource for resource in self._state["resources"] if resource["mode"] == "data"]},
            )

        new_state = {"resources": [resource for resource in self._state["resources"] if resource["type"] == name]}
        _logger.debug("new_state: {}".format(new_state))
        if len(new_state["resources"]) == 0:
            raise AttributeError("{} is not found".format(target_addr))

        return NodeResources(target_addr, new_state)

    def __getitem__(self, index):
        _logger.debug("index: {}".format(index))

        target_addr = (
            (self.address + "[" + str(index) + "]").removeprefix(".")
            if type(index) is int
            else (self.address + '["' + index + '"]').removeprefix(".")
        )
        _logger.debug("target_addr: {}".format(target_addr))

        _logger.debug("self._state: {}".format(self._state))

        new_state = [child_module for child_module in self._state if child_module["address"].startswith(target_addr)]
        if len(new_state) == 1:
            return NodeModule(target_addr, new_state[0])

        if len(new_state) >= 2:
            raise AttributeError("{} exists multiple, this is bug or state is broken...".format(target_addr))

        raise AttributeError("{} is not found".format(target_addr))


class NodeRoot(NodeModule):
    def __init__(self):
        cwd = os.environ.get("TF_PYTEST_DIR", "../terraform")
        state = json.loads(_exec_cmd(["terraform", "show", "-json"], cwd=cwd, print_stderr=True).stdout.decode("utf8"))

        super().__init__("", state["values"]["root_module"])
