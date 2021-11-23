variable "vm-cpu-num" {}
variable "vsphere-server" {}
variable "vsphere-user" {}
variable "vsphere-password" {}
variable "vsphere-datacenter" {}
variable "vsphere-cluster" {}
variable "vsphere-network" {}
variable "vsphere-datastore" {}
variable "vsphere-folder" {}
variable "vm-name" {}
variable "vm-mem-size" {}
variable "os-disk-size" {}
variable "disk-thin-provision" {}
variable "winadmin-password" {}
variable "os_iso_path" {}

  
  source "vsphere-iso" "windows2019" {
  CPUs                 = "${var.vm-cpu-num}"
  RAM                  = "${var.vm-mem-size}"
  RAM_reserve_all      = true
  cluster              = "${var.vsphere-cluster}"
  communicator         = "winrm"
  convert_to_template  = "true"
  datacenter           = "${var.vsphere-datacenter}"
  datastore            = "${var.vsphere-datastore}"
  disk_controller_type = ["lsilogic-sas"]
  firmware             = "bios"
  floppy_files         = ["autounattend.xml", "scripts/enable-winrm.ps1", "scripts/install-vm-tools.cmd"]
  folder               = "${var.vsphere-folder}"
  guest_os_type        = "windows9Server64Guest"
  insecure_connection  = "true"
  iso_paths            = ["${var.os_iso_path}", "[] /vmimages/tools-isoimages/windows.iso"]
  network_adapters {
    network      = "${var.vsphere-network}"
    network_card = "vmxnet3"
  }
  password = "${var.vsphere-password}"
  storage {
    disk_size             = "${var.os-disk-size}"
    disk_thin_provisioned = "${var.disk-thin-provision}"
  }
  username       = "${var.vsphere-user}"
  vcenter_server = "${var.vsphere-server}"
  vm_name        = "${var.vm-name}"
  winrm_password = "${var.winadmin-password}"
  winrm_timeout  = "1h30m"
  winrm_username = "Administrator"
}

build {
  sources = ["source.vsphere-iso.windows2019"]

  #Windows Update Plugin has already been downloaded inside container image
  #provisioner "windows-update" {
  #  search_criteria = "IsInstalled=0"
  #  filters = [
  #    "exclude:$_.Title -like '*Preview*'",
  #    "include:$true",
  #  ]
  #  update_limit = 1
  #}

  #Inserted reboot as sysprep step fails due to waiting for windows updates to install
  provisioner "windows-restart" {
    restart_timeout = "15m"
  }


  provisioner "windows-shell" {
    inline = ["C:\\windows\\System32\\Sysprep\\sysprep.exe /generalize /shutdown /quiet"]
  }
}