# ETH Node Infra

[![Smoke tests](https://github.com/ansybl/eth-infra/actions/workflows/smoketests.yml/badge.svg)](https://github.com/ansybl/eth-infra/actions/workflows/smoketests.yml)

Automates ETH node setup using Prysm for the beacon chain and Geth for the execution layer.
This is just a plain node setup with no staking involved.

## Architecture

Both Prysm and Geth have their own Compute instance and run within a docker container.
Both also have their own persistent disk used for the `datadir`.
The persistent disk is mount in `/mnt/disks/sdb/` on the host side and `/mnt/datadir` container side.

## Use

```sh
export WORKSPACE=mainnet
make docker/build
make docker/login
make docker/push
make devops/terraform/plan
make devops/terraform/apply
```

We leverage [Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) to handle state data instance separation.
In our setup the `WORKSPACE` matches with the network (e.g. `testnet`, `mainnet`), but can also be used to stand up a dedicated dev instance (e.g. `testnet-andre`).

## JWT Token deployment

The HTTP connection between your beacon node and execution node needs to be authenticated using a JWT Token.
This can be generated using the command below and deployed to the secret manager.

```sh
openssl rand -hex 32
```

Find out more: https://docs.prylabs.network/docs/execution-node/authentication

## Smoke tests

Run some tests against the execution node:

```sh
PROVIDER_URL=http://ip:8545 python utils/test_geth.py
```

If the node port is firewalled, it's possible to tunnel before running the tests:

```sh
ssh user@ip -L 0.0.0.0:8545:localhost:8545
```

Or alternatively using gcloud:

```sh
gcloud compute ssh --ssh-flag="-L 8545:localhost:8545" instance-name
```

Quick check that the node is accessible:

```sh
curl http://localhost:8545 \
--header 'Content-Type: application/json' \
--data '{"method": "net_version", "params": [], "id": 1, "jsonrpc": "2.0"}'
```
