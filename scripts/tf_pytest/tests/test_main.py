from tf_pytest.main import *


def test_apply(apply):
    print("some test")


def test_tfstate_node_root(apply):
    root = TfstateNodeRoot()
    print(root.state)
    print(root.time_static)
    print(root.time_static.default.values)

    print(root.module.some_module.state)

    print(root.data.http.default.values["url"])
