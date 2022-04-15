import votestorage.scripts.contract_functions as vote


def test_perform_voting():
    vote.deploy()

    vote.add_option("gasss")
    for j in range(13):
        vote.increment_vote("gasss")

    assert vote.get_count("gasss") == 13
