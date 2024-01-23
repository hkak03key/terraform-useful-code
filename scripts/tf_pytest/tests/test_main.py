from tf_pytest.main import *


def test_apply(apply):
    print("some test")


def test_tfstate_node_root(apply):
    root = TfstateNodeRoot()
    print(root._state)
