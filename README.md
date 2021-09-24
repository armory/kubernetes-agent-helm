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
With the selected AWS profile that has access to the target cluster Create a kubeconfig file
> Note: skip this in case the agent is set to run in 'agent' mode 

```sh
aws eks update-kubeconfig --name <target_cluster> 
```


### Agent mode:
From the root of the chart project:
```
helm install armory-agent . --set mode=agent,clientId=<your-clientId>,secret=<your/secret> --namespace=dev
```
### Infrastructure mode
```
helm install armory-agent . --set-file kubeconfig=$HOME/develop/config --set accountName=<your-accountName>,clientId=<your-clientId>,secret=<your/secret> --namespace=dev
```

> Note: if `cloudEnabled` is set to false there is no need to provide clientId and secret but you need to set clouddriver's grpc host in `grpcUrl` such as `--set grpcUrl= localhost:9090`

## Custom settings installation

You can also install using your own agent settings file if you would like greater flexibility:
```
helm template armory-agent . --set-file kubeconfig=$HOME/develop/config,agentyml=/Users/armory/.spinnaker/agent-local-hub.yml --namespace=dev
```
> Note: make sure that your `kubeconfigFile` in your settings file matches the kubeconfig set in the 'kubeconfig' variable if not running with `serviceAccount: true`

This chart also supports passing of settings using helm variables present in the values.yml
| Option | Default |
| ------ | ------ |
| grpcUrl | `agents.cloud.armory.io:443` |
| clientId | null |
| secret | null |
| cloudEnabled | `true` |
| kubernetes | refer to Kubernetes specific options in [armory.io](https://docs.armory.io/docs/armory-agent/agent-options/#configuration-options) |

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

