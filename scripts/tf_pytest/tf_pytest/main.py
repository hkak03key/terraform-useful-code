import json
import logging
import os
import subprocess
import sys
from abc import ABC, abstractmethod

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


class TfStateNode(ABC):
    @abstractmethod
    def __init__(self, address, state):
        self.address = address
        self.state = state


class TfstateNodeResources(TfStateNode):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        _logger.debug("self._state: {}".format(self.state))

        for resource in self.state["resources"]:
            if resource["address"] == target_addr:
                return TfstateNodeResource(target_addr, resource)

        raise AttributeError("{} is not found".format(target_addr))


class TfstateNodeDatas(TfStateNode):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        _logger.debug("self._state: {}".format(self.state))

        new_state = {"resources": [resource for resource in self.state["resources"] if resource["type"] == name]}
        _logger.debug("new_state: {}".format(new_state))
        if len(new_state["resources"]) == 0:
            raise AttributeError("{} is not found".format(target_addr))

        return TfstateNodeResources(target_addr, new_state)


class TfstateNodeResource(TfStateNode):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))

        if name in self.state.keys():
            return self.state[name]


class TfstateNodeModules(TfStateNode):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        _logger.debug("self._state: {}".format(self.state))

        for child_module in self.state["child_modules"]:
            if child_module["address"] == target_addr:
                return TfstateNodeModule(target_addr, child_module)

        raise AttributeError("{} is not found".format(target_addr))


class TfstateNodeModule(TfStateNode):
    def __init__(self, address, state):
        super().__init__(address, state)

    def __getattr__(self, name):
        _logger.debug("name: {}".format(name))
        target_addr = (self.address + "." + name).removeprefix(".")
        _logger.debug("target_addr: {}".format(target_addr))

        _logger.debug("self._state: {}".format(self.state))

        if name == "module":
            return TfstateNodeModules(target_addr, {"child_modules": self.state["child_modules"]})

        if name == "data":
            return TfstateNodeDatas(
                target_addr,
                {"resources": [resource for resource in self.state["resources"] if resource["mode"] == "data"]},
            )

        new_state = {"resources": [resource for resource in self.state["resources"] if resource["type"] == name]}
        _logger.debug("new_state: {}".format(new_state))
        if len(new_state["resources"]) == 0:
            raise AttributeError("{} is not found".format(target_addr))

        return TfstateNodeResources(target_addr, new_state)


class TfstateNodeRoot(TfstateNodeModule):
    def __init__(self):
        cwd = os.environ.get("TF_PYTEST_DIR", "../terraform")
        state = json.loads(_exec_cmd(["terraform", "show", "-json"], cwd=cwd, print_stderr=True).stdout.decode("utf8"))

        super().__init__("", state["values"]["root_module"])


if __name__ == "__main__":
    _config_root_logger()
