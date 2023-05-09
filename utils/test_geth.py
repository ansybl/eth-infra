"""
Simple script to verify basic RPC calls are working.
"""
import os

import requests

assert (PROVIDER_URL := os.environ.get("PROVIDER_URL")), "required env PROVIDER_URL"
HEADERS = {"Content-Type": "application/json"}


def requests_post(json):
    response = requests.post(PROVIDER_URL, json=json, headers=HEADERS)
    response.raise_for_status()
    return response


def net_version():
    data = {
        "method": "net_version",
        "params": [],
        "id": 1,
        "jsonrpc": "2.0",
    }
    response = requests_post(data)
    assert response.status_code == 200
    assert response.json().keys() == {"jsonrpc", "id", "result"}
    assert response.json()["result"] == "1"


def eth_get_block_by_number():
    block_number = "0xbeaf"
    data = {
        "method": "eth_getBlockByNumber",
        "params": [block_number, False],
        "id": 1,
        "jsonrpc": "2.0",
    }
    response = requests_post(data)
    assert response.status_code == 200
    assert response.json().keys() == {"jsonrpc", "id", "result"}
    assert response.json()["result"]["number"] == block_number


def eth_block_number():
    data = {
        "method": "eth_blockNumber",
        "params": [],
        "id": 1,
        "jsonrpc": "2.0",
    }
    response = requests_post(data)
    assert response.status_code == 200
    assert response.json().keys() == {"jsonrpc", "id", "result"}
    assert response.json()["result"].startswith("0x")


def eth_syncing():
    data = {
        "method": "eth_syncing",
        "params": [],
        "id": 1,
        "jsonrpc": "2.0",
    }
    response = requests_post(data)
    assert response.status_code == 200
    assert response.json().keys() == {"jsonrpc", "id", "result"}
    result = response.json()["result"]
    # would fail if the node is still syncing
    assert result == False, result


def eth_get_logs():
    data = {
        "method": "eth_getLogs",
        "params": [{"address": "0xdAC17F958D2ee523a2206206994597C13D831ec7"}],
        "id": 1,
        "jsonrpc": "2.0",
    }
    response = requests_post(data)
    assert response.status_code == 200
    assert response.json().keys() == {"jsonrpc", "id", "result"}
    assert isinstance(response.json()["result"], list)


def main():
    net_version()
    eth_get_block_by_number()
    eth_block_number()
    eth_syncing()
    eth_get_logs()


if __name__ == "__main__":
    main()
