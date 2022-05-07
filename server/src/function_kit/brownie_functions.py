import json
import brownie

from src.config import basedir


def brownie_run(method, kwargs={}):
    return brownie.run(
        script_path="scripts/contract_functions.py",
        method_name=method,
        kwargs=kwargs,
    )


def store_voter_ids(id):
    """
    stores upto 10 ids in a json file
    when called to add a 11th id, it dumps the json file's id into the blockchain and resets the json file
    """

    dump_file = basedir / "voter_dump.json"

    reset = False

    if dump_file.is_file():
        with open(dump_file) as f:
            data = json.load(f)

        if int(data["count"]) < 10:
            data["count"] += 1
            data["id_array"].append(id)
        else:
            brownie_run(method="set_voted", kwargs={"ids": data["id_array"]})
            reset = True

    else:
        reset = True

    if reset:
        data = {"count": 1, "id_array": [id]}

    with open(dump_file, "w") as f:
        json.dump(data, f)


def check_vote(id):
    dump_file = basedir / "voter_dump.json"

    voted = False  # Assume vote has already been cast from this id

    # Check json file
    if dump_file.is_file():
        with open(dump_file) as f:
            data = json.load(f)
            if id in data["id_array"]:
                voted = True

    # Check blockchain
    response = brownie_run(method="get_voted", kwargs={"id": id})
    if response:
        voted = True

    return voted
