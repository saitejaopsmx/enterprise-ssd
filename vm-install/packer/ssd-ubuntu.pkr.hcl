packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "release_tag" {
  type    = string
  default = "ami_image_creation_v1"
}

variable "iso_url" {
  type    = string
}

variable "iso_checksum" {
  type    = string
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "cpu_cores" {
  type    = string
  default = "2"
}

locals {
  image_name = "ubuntu-ssd"
}

source "qemu" "ubuntu_prebake" {
  iso_url            = var.iso_url
  iso_checksum       = var.iso_checksum
  iso_checksum_type  = "sha256"
  output_directory   = "output-qcow2"
  format             = "qcow2"
  accelerator        = "none"
  vm_name            = local.image_name
  ssh_username       = "ubuntu"
  ssh_password       = "ubuntu"
  disk_size          = 4096
  headless           = true

  qemuargs = [
    ["-m", "${var.memory}M"],
    ["-smp", var.cpu_cores]
  ]
}

build {
  name    = "ubuntu-prebake-build"
  sources = ["source.qemu.ubuntu_prebake"]

  provisioner "shell" {
    inline = [
      "set -euo pipefail",
      "RELEASETAG=${var.release_tag}",
      "curl -fSL -o bundle.sh https://raw.githubusercontent.com/OpsMx/enterprise-ssd/${var.release_tag}/vm-install/image-setup/bundle.sh",
      "curl -fSL -o version.env https://raw.githubusercontent.com/OpsMx/enterprise-ssd/${var.release_tag}/vm-install/image-setup/version.env",
      "chmod +x bundle.sh",
      "sed -i \"s/^RELEASETAG=.*/RELEASETAG=${var.release_tag}/\" version.env",
      "./bundle.sh",
      "sudo docker images",
      "./clean-before-build.sh",
      "sudo cloud-init clean",
      "sudo shutdown -h now"
    ]
  }

  post-processor "shell-local" {
    inline = [
      "echo 'Converting QCOW2 to VMDK...'",
      "qemu-img convert -O vmdk output-qcow2/${local.image_name} ${local.image_name}.vmdk",

      "echo 'Creating OVF descriptor...'",
      "cat > ${local.image_name}.ovf <<EOF",
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
      "<ovf:Envelope xmlns:ovf=\"http://schemas.dmtf.org/ovf/envelope/1\">",
      "  <ovf:References>",
      "    <ovf:File ovf:id=\"file1\" ovf:href=\"${local.image_name}.vmdk\" ovf:size=\"$(stat -c%s ${local.image_name}.vmdk)\"/>",
      "  </ovf:References>",
      "  <ovf:DiskSection>",
      "    <ovf:Disk ovf:diskId=\"disk1\" ovf:fileRef=\"file1\" ovf:capacity=\"4294967296\"/>",
      "  </ovf:DiskSection>",
      "  <ovf:VirtualSystem ovf:id=\"${local.image_name}\">",
      "    <ovf:Name>${local.image_name}</ovf:Name>",
      "  </ovf:VirtualSystem>",
      "</ovf:Envelope>",
      "EOF",

      "echo 'Creating OVA...'",
      "tar -cvf ${local.image_name}.ova ${local.image_name}.ovf ${local.image_name}.vmdk",
      "echo '✅ OVA generation complete: ${local.image_name}.ova'"
    ]
  }
}

