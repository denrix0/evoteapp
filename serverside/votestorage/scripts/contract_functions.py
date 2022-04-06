# password is passy
from brownie import accounts, config, VoteStorage, network


def get_account():
    if network.show_active() == "development":
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy():
    account = get_account()
    vote_storage = VoteStorage.deploy({"from": account})

    return vote_storage


def main():
    deploy()
