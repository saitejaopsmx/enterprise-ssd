
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


  ```console
  $ kubectl create namespace mynamespace
  ```

## Create your git-repo
*SSD stores all the configuration in a repo, typically a 'git repo', though bitbucket, S3 and others are supported.*

1. Create an empty-repo (called the "gitops-repo" in the document), "main" branch should be the default, and clone it locally
2. Clone https://github.com/OpsMx/enterprise-ssd:

`git clone https://github.com/OpsMx/enterprise-ssd`

3. Copy contents of the enterprise-ssd to the gitops-repo created above using:

`cp -r enterprise-ssd/* gitops-repo` # Replace "gitops-repo" with your repo-name

and cd to the gitops-repo e.g. `cd gitops-repo`

## Specify inputs based on your environment and git-repo
*The installation process requires inputs such as the application version, git-repo details and so on.*

4. **Update Values.yaml as required**, specifically: At at **minimum** the SSD URL and gitops-repo details in spinnaker.gitopsHalyard section must be updated.Full values.yaml is available at: https://github.com/OpsMx/enterprise-ssd/blob/main/charts/oes/values.yaml

## Start the installation
*The installation is done through helm.*

5. Install SSD by executing this command:

`helm install <release-name> charts/oes -f <values.yaml> -n <Namespace> --timeout=20m`

## Monitor the installation process
6. Wait for all pods to stabilize (about 10-20 min, depending on your cluster load). The "oes-config" in Completed status indicates completion of the installation process. Check status using:

- `kubectl -n <Namespace> get po -w`

  ## Check the installation
7. Access SSD using the URL specified in the values.yaml in step 5 in a browser such as Chrome.
8. Login to the SSD instance with user/password as admin and opsmxadmin123, if using the defaults for build-in LDAP.

      
