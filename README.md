<p align="center">
	<img src="img/opsmx.png" width="20%" align="center" alt="OpsMx">
</p>

# OpsMx Secure Software Delivery

For more information, visit https://www.opsmx.com

## Spinnaker + OpsMx Secure Software Delivery (SSD) Setup Instructions

### Prerequisites

- Kubernetes cluster 1.19 or later with at least 6 cores and 20 GB memory
- Helm 3 is setup on the client system
  ```console
  $ helm version
  ```
  If helm is not setup, follow <https://helm.sh/docs/intro/install/> to install helm.

- Your Kubernetes cluster shall support persistent volumes

- It is assumed that an nginx ingress controller is installed on the cluster, by default ingress resources are created for oes-ui, oes-gate, spin-deck and spin-gate services. Customize the hosts for OES using the options in the values.yaml under oesUI, oesGate, spinDeck, spinGate. If any other ingress controller is installed, set createIngress flag to false and configure your ingress.

- To enable mutual TLS for Spinnaker Services and SSL features provided by Spinnaker Life Cycle Management (LCM), it is required to install nginx ingress from kubernetes community and cert-manager before installing OES. Please refer the table below for options to be enabled for LCM
  Instructions to install nginx ingress
  https://kubernetes.github.io/ingress-nginx/deploy/

  Instructions to install cert-manager
  https://cert-manager.io/docs/installation/kubernetes/

- Helm v3 expects the namespace to be present before helm install command is run. If it does not exists,

  ```console
  $ kubectl create namespace mynamespace
  ```

- To install the chart with the release name `my-release`:

	Helm v3.x
  ```console
  $ helm install my-release opsmx/oes [--namespace mynamespace] --timeout 15m
  ```

The command deploys OES on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

Helm v3.x
  ```console
  $ helm uninstall my-release [--namespace mynamespace]
  ```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Create your git-repo
*ISD stores all the configuration in a repo, typically a 'git repo', though bitbucket, S3 and others are supported.*

1. Create an empty-repo (called the "gitops-repo" in the document), "main" branch should be the default, and clone it locally
2. Clone https://github.com/OpsMx/enterprise-ssd, selecting the appropriate branch:

`git clone https://github.com/OpsMx/standard-isd-gitops  -b main`

3. Copy contents of the standard-isd-repo to the gitops-repo created above using:

`cp -r standard-isd-gitops/* gitops-repo` # Replace "gitops-repo" with your repo-name

and cd to the gitops-repo e.g. `cd gitops-repo`

## Specify inputs based on your environment and git-repo
*The installation process requires inputs such as the application version, git-repo details and so on.*

4. **Update Values.yaml as required**, specifically: At at **minimum** the ISD URL and gitops-repo details in spinnaker.gitopsHalyard section must be updated.Full values.yaml is available at: https://github.com/OpsMx/enterprise-ssd/blob/main/charts/oes/values.yaml

## Start the installation
*The installation is done through helm.*

5. Installation ISD by executing this command:

`helm install <release-name> charts/oes -f <values.yaml> -n <Namespace> --timeout=20m`

## Monitor the installation process
6. Wait for all pods to stabilize (about 10-20 min, depending on your cluster load). The "oes-config" in Completed status indicates completion of the installation process. Check status using:

- `kubectl -n opsmx-isd get po -w`

**NOTE-1**: If the pod starting with isd-install-* errors out, please check the logs as follows, replacing the pod-name correctly:
- `kubectl -n opsmx-isd logs isd-install-tjzlx -c get-secrets`
- `kubectl -n opsmx-isd logs isd-install-tjzlx -c git-clone`
- `kubectl -n opsmx-isd logs isd-install-tjzlx -c apply-yamls`

  ## Check the installation
7. Access ISD using the URL specified in the values.yaml in step 5 in a browser such as Chrome.
8. Login to the ISD instance with user/password as admin and opsmxadmin123, if using the defaults for build-in LDAP.

      
