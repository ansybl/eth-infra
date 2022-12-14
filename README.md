# ETH Node Infra

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
