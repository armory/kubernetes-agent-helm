# Helm Chart for kubernetes agent
> Built with Helm v3.6.3

The main intention with this project is to provide an easy way of installing armory's Agent for Kubernetes

## Features

- Allows to easily deploy armory's agent for kubernetes with a single command
- Allows to customize the agent settings passing a custom file

## Requirements
- possibly helm v3.6.3 (haven't tested with anything prior)
- An existing kubernetes cluster and a namespace in case you don't want to use 'default'
- A kubeconfig file in case the agent is set to run in 'infrastructure' mode

## Usage

- `helm install release-name path-of-the-chart --namespace=your-namespace`
- `helm unisntall release-name --namespace=your-namespace`

> The release name is used across some of the kubernetes resources that get created, you can also add `--set imagePullSecrets=something` to use  docker registry credentials

## Quick Installation
> Note: you can also replace `helm install` by `helm template` in the below commands to get an output of the kubernetes manifests that are rendered e.g: `helm template armory-agent ...`

Create a namespace where the agent will be installed:

```sh
kubectl create namespace dev
```

> Note: if `cloudEnabled` is set to false there is no need to provide clientId
> and clientSecret in the following examples. You will, however, need to set
> clouddriver's grpc host in `grpcUrl` such as `--set grpcUrl= localhost:9090`

### Agent mode:
From the root of the chart project:
```
helm install armory-agent . --set mode=agent,clientId=<your-clientId>,clientSecret=<your/secret> --namespace=dev
```

### Infrastructure mode

This mode allows you to configure multiple Kubernetes clusters managed by a
single agent installation.

```shell
helm install armory-agent armory/agent-k8s \
  --namespace=dev \
  # NOTE: you can also embed your kubeconfig in the values.yaml file for cleaner
  #       definition. See the values.yaml file in this project for an example.
  --set-file accounts[0].kubeconfig=$HOME/develop/config \
  --set mode=infrastructure,\
        clientId=<your-clientId>,\
        clientSecret=<your/secret>
```

## Chart Values

| Key | Type | Default | Description |
| ------ | ------ | ------ | ------ |
| `mode` | string | `agent` | Required. The mode the agent will run in. Either `agent` or `infrastructure`. |
| `grpcUrl` | string | `agents.cloud.armory.io:443` | Required. The URL to connect to Armory Cloud. |
| `cloudEnabled` | bool | `true` | Whether this agent will talk to Armory Cloud, or an in-cluster Armory Enterprise instance. |
| `clientId` | string | null | Client ID surfaced when [registering your Armory Cloud instance][ac-registration]. Required if cloudEnabled is true. |
| `clientSecret` | string | null | Client Secret surfaced when [registering your Armory Cloud instance][ac-registration]. Required if cloudEnabled is true. |
| `accountName` | string | null | Name of the account this agent is monitoring. Required if mode is set to 'agent'. |
| `accounts` | list | null | Configure multiple Kubernetes accounts when running in infrastructure mode. Refer to Kubernetes specific options [here](https://docs.armory.io/docs/armory-agent/agent-options/#configuration-options). Required if mode is set to 'infrastructure'. |
| `env` | list | null | Optional. Configure additional environment variables for the agent. |

[ac-registration]: https://docs.armory.io/docs/installation/ae-environment-reg/

## Further customization

If you'd like complete control over the agent's configuration we recommend
using the `armory-k8s-full` chart which can be found
[here](https://github.com/armory-io/agent-k8s/tree/master/deploy/charts/armory-k8s-full).

## GitHub Actions

### Create Helm Package After Agent Release

This workflow is exposed by GitHub API, and it basically creates and publish the agent-k8s component
into a helm package. 

It was meant to be use by [armory-io/agent-k8s](https://github.com/armory-io/agent-k8s/blob/5b914180aea2602f0a6152e34194463b26b45177/.github/workflows/build.yml) 
workflow when there is a new release of it, but we always can trigger it by calling the GitHub API.

Calling GitHub API using curl command:

```
    curl -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token {GIT_HUB_TOKEN}" \
        https://api.github.com/repos/{REPOSITORY_OWNER}/{REPOSITORY_NAME}/dispatches \
        -d '{"event_type":"agentRelease", "client_payload":{"version":"{HELM_VERSION}", "appVersion":"{AGENT_VERSION}"}}'
```

## License

© 2021 Armory Inc. All rights reserved.
