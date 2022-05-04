import requests
import json

from crypto_functions import AESKey, RSAKey, generate_master_token
from voterid.totpclient import get_totp_token


def send_api_request(path=None, method="GET", body=None, auth=None):
    url = "https://127.0.0.1:5000/"

    if path:
        url += path

    headers = {"Content-Type": "application/json"}

    if auth:
        headers["Authorization"] = auth

    if method == "GET":
        response = requests.get(url, verify=False)
    if method == "POST":
        response = requests.post(
            url, data=json.dumps(body), headers=headers, verify=False
        )

    return response.json()


def test_vote_process():
    errors = []

    # Test Login
    auth = send_api_request("login", "POST", body={"id": "6", "pin": "420"})

    if "error_type" not in auth:
        for key in ["jwt", "pub_key"]:
            if key not in auth:
                errors.append(key + " is missing from auth response")
    else:
        errors.append(("Login Error: " + auth["message"]))

    jwt = auth["jwt"]
    pub_key = auth["pub_key"]

    if jwt:
        # Test Authentication Methods
        auth_list = ["uid", "totp1", "totp2"]
        data = {"auth_type": "", "auth_content": "", "enc_key": "", "iv": ""}

        totp_secrets = {
            "totp1": "NWPMAEPRA64K7CSMRMNVRXIY6X56XSRK",
            "totp2": "W4XOKAYQ27N544RHOZJPKI744F3HKKIW",
        }

        tokens = {}

        for meth in auth_list:
            key, iv = AESKey.generate()
            data["auth_type"] = meth
            data["enc_key"] = RSAKey.encrypt(pub_key, key)
            data["iv"] = RSAKey.encrypt(pub_key, iv)

            if meth == "uid":
                data["auth_content"] = "000000000000000"
            else:
                data["auth_content"] = get_totp_token(secret=totp_secrets[meth])

            data["auth_content"] = AESKey.encrypt(
                msg=data["auth_content"], key=key, iv=iv
            )

            auth_response = send_api_request("auth_verify", "POST", body=data, auth=jwt)

            if "error_type" in auth_response:
                errors.append(("Authentication Error: " + auth_response["message"]))
            else:
                tokens[meth] = auth_response["token"]

        # Test Vote Form Fetching
        vote_form = send_api_request("vote_form", "GET")

        for key in ["prompt", "options"]:
            if key not in vote_form:
                errors.append((key + " is missing from vote form"))

        # Test Vote Submission

        master_token = generate_master_token(
            tokens["uid"], tokens["totp1"], tokens["totp2"]
        )

        data = {"master_token": "", "form_option": "", "enc_key": "", "iv": ""}

        key, iv = AESKey.generate()

        data["master_token"] = AESKey.encrypt(msg=master_token, key=key, iv=iv)
        data["enc_key"] = RSAKey.encrypt(pub_key, key)
        data["iv"] = RSAKey.encrypt(pub_key, iv)
        data["form_option"] = AESKey.encrypt(
            msg=vote_form["options"][0], key=key, iv=iv
        )

        sub_response = send_api_request("submit", "POST", body=data, auth=jwt)

        if "error_type" in sub_response:
            errors.append(("Submission Error: " + sub_response["message"]))

    assert not errors, "\nErrors :\n-------\n{}".format("\n".join(errors))
