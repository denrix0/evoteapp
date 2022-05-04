import brownie
from pathlib import Path
import os

proj = brownie.project.load(
    (Path(os.path.dirname(os.path.realpath(__file__))).parent / "votestorage").resolve()
)
brownie.network.connect("development")
proj.load_config()


def brownie_run(method, kwargs={}):
    return brownie.run(
        script_path="scripts/contract_functions.py",
        method_name=method,
        kwargs=kwargs,
    )


brownie_run(method="deploy")

print(brownie_run("get_voted", kwargs={"id": "0"}))
