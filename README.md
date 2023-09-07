# enterprise-ssd
This repo is used for installing the SSD


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

## Monitor the installation process
5. Wait for all pods to stabilize (about 10-20 min, depending on your cluster load). The "oes-config" in Completed status indicates completion of the installation process. Check status using:

    ```console
    $ kubectl -n opsmx-ssd get po -w
    ```

## TroubleShooting

1. Please change the echo image by using the below command

    ```console
    $ kubectl set image deploy spin-echo-scheduler echo-scheduler=quay.io/opsmxpublic/ubi8-oes-echo:b5dad694-OP-21052-v4.0-Testing -n opsmx-ssd
    ```

    ```console
    $ kubectl set image deploy spin-echo-worker echo-worker=quay.io/opsmxpublic/ubi8-oes-echo:b5dad694-OP-21052-v4.0-Testing -n opsmx-ssd
    ``` 

  ## Check the installation
5. Access SSD using the URL specified in the values.yaml in step 5 in a browser such as Chrome.
6. Login to the SSD instance with user/password as admin and opsmxadmin123, if using the defaults for build-in LDAP.

      

