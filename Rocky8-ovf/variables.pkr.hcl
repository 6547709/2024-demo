// vSphere Credentials
variable "vsphere_server" {
  type        = string
  description = "The fully qualified domain name or IP address of the vCenter Server instance. (e.g. 'mgmt-vc.corp.local')"
}
variable "vsphere_user" {
  type        = string
  description = "The username to login to the vCenter Server instance. (e.g. 'svc-packer-vsphere@corp.local')"
  sensitive   = true
}
variable "vsphere_password" {
  type        = string
  description = "The password for the login to the vCenter Server instance."
  sensitive   = true
}
variable "vsphere_insecure_connection" {
  type        = bool
  description = "Do not validate vCenter Server TLS certificate."
  default     = true
}

// vSphere Settings
variable "vsphere_datacenter" {
  type        = string
  description = "The name of the target vSphere datacenter. (e.g. 'VVF-DC')"
}
variable "vsphere_cluster" {
  type        = string
  description = "The name of the target vSphere cluster. (e.g. 'VVF-Cluster')"
}
variable "vsphere_datastore" {
  type        = string
  description = "The name of the target vSphere datastore. (e.g. 'ST-10T')"
}
variable "vsphere_network" {
  type        = string
  description = "The name of the target vSphere network segment. (e.g. 'VLAN4041')"
}
variable "vm_folder" {
  type        = string
  description = "The name of the target vSphere folder. (e.g. 'templates')"
}

variable "iso_url" {
  type        = string
  description = "The os install image path. (e.g. '[ST-10T] ISO/rocky8-dvd.iso')"
}

// Virtual Machine Settings
variable "linux_ssh_password" {
  type        = string
  description = "The password to login to the guest operating system."
  sensitive   = true
}

variable "template_version" {
  type        = string
  description = "The version of the template."
}

variable "vm_cpu_num" {
  type        = string
  description = "The number of virtual CPUs. (e.g. '4')"
}

variable "vm_cpu_cores_num" {
  type        = string
  description = "The number core per vCPU. (e.g. '4')"
}

variable "vm_disk_size" {
  type        = string
  description = "The size for the virtual disk in MB. (e.g. '102400')"
}

variable "vm_mem_size" {
  type        = string
  description = "The size for the virtual memory in MB. (e.g. '2048')"
}

variable "vm_video_ram" {
  type        = string
  description = "The size for the virtual video in KB. (e.g. '8192')"
}

variable "vm_name" {
  type        = string
  description = "The number of vm template. (e.g. 'Centos-T')"
}


variable "vm_version" {
  type        = string
  description = "Define the virtual machine hardware version number. (e.g. '19' for vSphere 7.0)"
}

variable "vsphere_content_library" {
  type        = string
  description = "The name of the target content library. (e.g. 'dc02-vm-templates')"
}

