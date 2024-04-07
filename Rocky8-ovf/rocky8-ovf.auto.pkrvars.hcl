/*
    DESCRIPTION:
    Rocky Linux 8 variables used by the Packer Plugin for VMware vSphere (vsphere-iso).
*/
// vSphere Config
vsphere_server          = "mgmt-vc03.corp.local"
vsphere_user            = "Administrator@vsphere.local"
vsphere_password        = "VMware1!"
vsphere_datacenter      = "VVF-DC"
vsphere_cluster         = "VVF-Cluster"
vsphere_content_library = "VM-Templates"
vm_folder               = "VM-Templates"
vsphere_datastore       = "ST-10T"

// Rocky Install Media
iso_url = "[ST-ISO] 000ISO/Rocky-8.9-x86_64-dvd1.iso"

// Virtual Machine Hardware Settings
template_version = "1.0.0"
vm_name          = "Rocky8-OVF"
vsphere_network  = "dvpg-vlan4043"
vm_cpu_num       = 4
vm_cpu_cores_num = 4
vm_mem_size      = 4096
vm_disk_size     = 102400
vm_video_ram     = 8192
vm_version       = 19


//Guest Operating System Metada
linux_ssh_password = "VMware123!"
