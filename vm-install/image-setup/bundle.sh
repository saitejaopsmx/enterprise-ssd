#!/bin/bash

# Set the path to your version file
VERSION_FILE="./version.env"

# Check if the file exists
if [[ -f "$VERSION_FILE" ]]; then
  source "$VERSION_FILE"
else
  echo "[ERROR] version.env file not found. Aborting."
  exit 1
fi

CHARTVERSION=$1
RELEASETAG=$2

sudo apt-get update
sudo apt install -y docker.io
sudo apt install -y git
sudo snap install helm --classic
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  -O /usr/local/bin/yq
sudo chmod 755 /usr/local/bin/yq

sudo mkdir opsmxssd

curl -o opsmxssd/default-ssd-minimal-values.yaml https://raw.githubusercontent.com/OpsMx/enterprise-ssd/$RELEASETAG/charts/ssd/ssd-minimal-values.yaml
curl -o opsmxssd/install.sh https://raw.githubusercontent.com/OpsMx/enterprise-ssd/$RELEASETAG/vm-install/image-setup/install.sh
curl -o opsmxssd/add-dns-entry-in-local.sh https://raw.githubusercontent.com/OpsMx/enterprise-ssd/$RELEASETAG/vm-install/image-setup/add-dns-entry-in-local.sh
curl -o opsmxssd/fetch-ssl-cert.sh https://raw.githubusercontent.com/OpsMx/enterprise-ssd/$RELEASETAG/vm-install/image-setup/fetch-ssl-cert.sh
curl -o ssd-install.sh https://raw.githubusercontent.com/OpsMx/enterprise-ssd/$RELEASETAG/vm-install/image-setup/extract-images-list.sh
curl -o ssd-install.sh https://raw.githubusercontent.com/OpsMx/enterprise-ssd/$RELEASETAG/vm-install/image-setup/pull-images.sh
curl -o ssd-install.sh https://raw.githubusercontent.com/OpsMx/enterprise-ssd/$RELEASETAG/vm-install/image-setup/clean-before-build.sh

chmod +x opsmsssd/install.sh
chmod +x opsmxssd/add-dns-entry-in-local.sh
chmod +x opsmxssd/fetch-ssl-cert.sh
chmod +x extract-images-list.sh
chmod +x pull-images.sh
chmod +x clean-before-build.sh

# Replace CHARTVERSION in install.sh with actual value
sed -i "s/--version CHARTVERSION/--version ${CHARTVERSION}/" opsmsssd/install.sh

helm repo add opsmxssd https://opsmx.github.io/enterprise-ssd/
helm repo update

# dry run of helm install
helm template opsmxssd opsmxssd/ssd --version $CHARTVERSION >rendered.yaml

./extract-images-list.sh rendered.yaml image-list.txt

cat image-list.txt

# Install k3s (in Docker mode for image reuse)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-name=ssd-primary --docker --disable=traefik" sh -

sudo k3s kubectl wait --for=condition=Ready nodes --all --timeout=90s
sudo k3s kubectl get nodes

# Set up kubeconfig and install nginx ingress and cert-manager
# below commands are clubbed and run as root user
sudo bash -c ' \
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml && \
  helm repo add jetstack https://charts.jetstack.io && \
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
  helm repo update && \
  helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager --create-namespace --set installCRDs=true && \
  helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx --create-namespace '

./pull-images.sh image-list.txt
