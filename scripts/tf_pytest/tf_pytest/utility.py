import logging
import os
import subprocess

# logger
_logger = logging.getLogger(__name__)
_logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def exec_cmd(cmd, cwd, print_stdout=False, print_stderr=False):
    _logger.info("exec_cmd: {}...".format(" ".join(cmd)))
    proc = subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if proc.returncode != 0:
        _logger.error("exec_cmd: `{}` is failed.".format(" ".join(cmd)))
        _logger.error("stdout: {}".format(proc.stdout.decode("utf8")))
        _logger.error("stderr: {}".format(proc.stderr.decode("utf8")))
        raise subprocess.CalledProcessError(proc.returncode, cmd)

    if print_stdout:
        print(proc.stdout.decode("utf8"))
    if print_stderr:
        print(proc.stderr.decode("utf8"))

    return proc
