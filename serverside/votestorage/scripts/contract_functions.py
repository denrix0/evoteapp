# password is passy
import json

from brownie import accounts, config, VoteStorage, network


def get_account():
    if network.show_active() in ["development", "ganache-local"]:
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy():
    account = get_account()
    vote_storage = VoteStorage.deploy({"from": account})

    return vote_storage


def add_node(node):
    tx = VoteStorage[-1].addNode(node, {"from": get_account()})
    tx.wait(1)


def remove_node(node):
    tx = VoteStorage[-1].removeNode(node, {"from": get_account()})
    tx.wait(1)


def add_option(option_name):
    tx = VoteStorage[-1].addOption(option_name, {"from": get_account()})
    tx.wait(1)


def reset_option():
    tx = VoteStorage[-1].resetOptions({"from": get_account()})
    tx.wait(1)


def increment_vote(option_name):
    tx = VoteStorage[-1].incrementVote(option_name, {"from": get_account()})
    tx.wait(1)


def get_count(option_name):
    tx = VoteStorage[-1].getVoteCount(option_name)

    return tx


def write_votes_json(option_list=None, json_file="dump.json"):
    """
    option_list = list of option names
    json_file = Location of json file
    """
    print(json_file)
    data = {}
    for option in option_list:
        data[option] = get_count(option)

    with open(json_file, "w") as f:
        json.dump(data, f)
