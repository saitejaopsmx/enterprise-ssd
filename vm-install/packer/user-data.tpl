#cloud-config
users:
  - default
  - name: ubuntu
    gecos: Ubuntu User
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    shell: /bin/bash
    lock_passwd: true

runcmd:
  - echo "RELEASETAG=${RELEASETAG}"
  - curl -fSL -o bundle.sh "https://raw.githubusercontent.com/OpsMx/enterprise-ssd/${RELEASETAG}/vm-install/image-setup/bundle.sh"
  - curl -fSL -o version.env "https://raw.githubusercontent.com/OpsMx/enterprise-ssd/${RELEASETAG}/vm-install/image-setup/version.env"
  - chmod +x bundle.sh
  - sed -i "s/^RELEASETAG=.*/RELEASETAG=${RELEASETAG}/" version.env
  - ./bundle.sh
  - sudo docker images
  - ./clean-before-build.sh
  - rm -f bundle.sh version.env clean-before-build.sh
  - sudo cloud-init clean
  - sudo shutdown -h now
