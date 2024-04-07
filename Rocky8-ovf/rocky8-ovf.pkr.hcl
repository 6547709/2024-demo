packer {
  required_version = ">= 1.10.2"
  required_plugins {
    vsphere = {
      version = ">= v1.2.7"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}
source "vsphere-iso" "rocky8" {
  firmware        = "efi-secure"
  CPUs            = var.vm_cpu_num
  cpu_cores       = var.vm_cpu_cores_num
  RAM             = var.vm_mem_size
  RAM_reserve_all = false
  boot_command = [
    "<up>",
    "e",
    "<down><down><end><wait>",
    " text inst.ks=hd:sr1:/ks.cfg",
    "<enter><wait><leftCtrlOn>x<leftCtrlOff>"
  ]
  boot_order           = "disk,cdrom"
  boot_wait            = "10s"
  cluster              = var.vsphere_cluster
  convert_to_template  = false
  datacenter           = var.vsphere_datacenter
  datastore            = var.vsphere_datastore
  disk_controller_type = ["pvscsi"]
  export {
    force            = true
    output_directory = "./output_vsphere"
  }
  folder              = var.vm_folder
  guest_os_type       = "rhel8_64Guest"
  insecure_connection = "true"
  ip_wait_timeout     = "60m"
  ip_settle_timeout   = "2m"
  ip_wait_address     = "10.0.0.0/8"
  iso_paths           = [var.iso_url]
  cd_files            = ["./ks.cfg"]
  cd_label            = "OEMDRV"
  network_adapters {
    network      = var.vsphere_network
    network_card = "vmxnet3"
  }
  notes        = "Build via Packer, Version:${var.template_version} ."
  password     = var.vsphere_password
  remove_cdrom = "true"
  ssh_password = var.linux_ssh_password
  ssh_username = "root"
  ssh_timeout  = "20m"
  storage {
    disk_size             = var.vm_disk_size
    disk_thin_provisioned = true
  }
  username       = var.vsphere_user
  vcenter_server = var.vsphere_server
  video_ram      = var.vm_video_ram
  vm_name        = "${var.vm_name}-${var.template_version}"
  vm_version     = var.vm_version
}

build {
  sources = ["source.vsphere-iso.rocky8"]
  provisioner "shell" {
    inline = [
      "echo 'exclude=vdo* kmod-kvdo* kernel* redhat-release*' >> /etc/yum.conf",
      "echo 'exclude=vdo* kmod-kvdo* kernel* redhat-release*' >> /etc/dnf/dnf.conf",
      "echo 'minrate=1' >> /etc/yum.conf",
      "echo 'timeout=30000' >> /etc/dnf/dnf.conf",
      "mkdir -p /usr/local/customization/",
      "dnf remove cups -y",
      "dnf update -y",
      "rm -rf /root/*.cfg",
      "dnf autoremove -y",
      "dnf clean all -y",
      "rm -rf /root/.ssh /home/ops/.ssh",
      "rm -rf /etc/ssh/*_key /etc/ssh/*.pub",
      "rm -rf /tmp/*",
      "sed -i 's/^HISTSIZE=1000/HISTSIZE=5000/' /etc/profile",
      "cat /dev/null > /var/log/wtmp /var/log/lastlog /var/log/messages",
    ]
    pause_before        = "10s"
    start_retry_timeout = "1m"
  }
  provisioner "file" {
    destination = "/etc/rc.d/rc.local"
    source      = "files/rc.local"
  }

  provisioner "file" {
    destination = "/usr/local/customization/setup.sh"
    source      = "files/setup.sh"
  }

  provisioner "shell" {
    inline = ["chmod +x /etc/rc.d/rc.local", "chmod +x /usr/local/customization/setup.sh"]
  }

  post-processor "shell-local" {
    inline = [
      "export VM_NAME=${var.vm_name}",
      "export TEMPLATE_VERSION=${var.template_version}",
      "export VSPHERE_NETWORK=${var.vsphere_network}",
      "cd files",
      "chmod +x ./CustomizeOvf.sh",
      "./CustomizeOvf.sh"
    ]
  }
  post-processor "shell-local" {
    inline = [
      "export GOVC_URL=${var.vsphere_server}",
      "export GOVC_USERNAME=${var.vsphere_user}",
      "export GOVC_PASSWORD=${var.vsphere_password}",
      "export VSPHERE_CONTENT_LIBRARY=${var.vsphere_content_library}",
      "export VM_NAME=${var.vm_name}",
      "export TEMPLATE_VERSION=${var.template_version}",
      "cd files",
      "chmod +x ./UploadOvfToVCenter.sh",
      "./UploadOvfToVCenter.sh"
    ]
  }

}

