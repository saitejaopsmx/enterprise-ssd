# enterprise-ssd
This repo is used for installing the SSD
# OpsMx Secure Software Delivery
For more information, visit https://www.opsmx.com

## OpsMx Secure Software Delivery (SSD) Setup Instructions
SSD can be installed in the following ways, depending on your requirements

### Look and See
We can install SSD on a laptop with minikube, k3s, Docker Desktop, etc.
The instructions for doing this as are follows:
- kubectl apply -f <URL to be filled"
- Get the user/password for logging in: user: admin, the password is in the secret poc-passwords in the try-ssd namespace
- kubectl -n try-ssd port-forward svc/oes-ui 8080
- Go to your browser, http://localhost:8080
- if you have argocd installed locally, configure it using instructions here.

### Poc install
The same instructios above can be used for POC as well. However, we need to integrate with an SSO, we will need URLs, so access to a DNS and ingress/LB is required.
- This is a helm based installation where we start with a minimal*values.yaml based on your requirements
- If integration with an SSO is not required, choose minimal-poc-values.yaml
- If integrating with SAML, choose minimal-saml-values.yaml
- For all other SSOs, choose minimal-dex-values.yaml. We will need to configure the [dex connector](https://dexidp.io/docs/connectors/) based on your backend (e.g. google auth, AWS, etc.)
- Edit as required w.r.t. the URL, ingress, etc. Comments are in the file.
- execute:
  ```helm install <chart-name> ssd -f minimal-saml-values-modifled.yaml -n poc-ssd
- Navigate to <your base URL>/diagnostics to fix any issues

### Production install
In addition to the Poc Install instructions, this requires that we install the product in HA, have external storage and redis.
-


### Prerequisites

- Kubernetes cluster 1.19 or later with at least 6 cores and 20 GB memory
- Helm 3 is setup on the client system

  ```console
  $ helm version
  ```
  If helm is not setup, follow <https://helm.sh/docs/intro/install/> to install helm.


  ```console
  $ kubectl create namespace opsmx-ssd
  ```


1. Clone the repo enterprise-ssd repo

    ```console
    $ git clone https://github.com/OpsMx/enterprise-ssd.git
    ```

## Specify inputs based on your environment and git-repo
*The installation process requires inputs such as the application version, git-repo details and so on.*

2. **Update rcimages-values.yaml as required**, specifically: At at **minimum** the SSD URL and gitops-repo details in spinnaker.gitopsHalyard section must be updated.Full values.yaml is available at: https://github.com/OpsMx/enterprise-ssd/blob/main/charts/oes/values.yaml

## Start the installation
*The installation is done through helm.*

3. cd to the enterprise-ssd
  
    ```console
    $ cd enterprise-ssd/charts/ssd
    ```

4. Install SSD by executing this command:

    ```console
    $ helm install ssd charts/ssd -f rcimages-values.yaml -n opsmx-ssd --timeout=20m
    ```

5. Adding the DGraph Schema
   
   Run the below commands one by one

   ```console
   curl -o schema.graphql https://raw.githubusercontent.com/OpsMx/argocd-ssd/main/schema.graphql

   curl -o script.sh https://raw.githubusercontent.com/OpsMx/argocd-ssd/main/script.sh

   chmod +x script.sh

   kubectl -n opsmx-ssd cp script.sh dgraph-0:/tmp/ -c alpha

   kubectl -n opsmx-ssd cp schema.graphql dgraph-0:/tmp/ -c alpha

   kubectl exec -n opsmx-ssd dgraph-0 -c alpha -- /bin/sh -c "`cat script.sh`"
   ```

## Monitor the installation process
5. Wait for all pods to stabilize (about 10-20 min, depending on your cluster load). The "oes-config" in Completed status indicates completion of the installation process. Check status using:

    ```console
    $ kubectl -n opsmx-ssd get po -w
    ```

## Check the installation
5. Access SSD using the URL specified in the values.yaml in step 5 in a browser such as Chrome.
6. Login to the SSD instance with user/password as admin and opsmxadmin123, if using the defaults for build-in LDAP.

      
## TroubleShooting

1. If any of the Spinnaker pods are unable to start . Please comment the volumes section in the service-settings of each service.


## Use below document to Integrate Spinnaker with SSD

 https://docs.google.com/document/d/1T8mJgymIv3z5EI_ZtsqrguqLGBDygTwbp-emZ-Vq020/edit

## Use below document to Integrate Argo with SSD

 https://docs.google.com/document/d/1-p8TkyziN-vvG5skmMMoegnlvwIi9Q2Uc6IzDdOfD3E/edit
