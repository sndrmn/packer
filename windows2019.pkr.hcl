#Sample: Build Windows2019 vShere Templates

#packer {
#  required_plugins {
#    windows-update = {
#      version = "0.14.0"
#      source = "github.com/rgl/windows-update"
#    }
#  }
#}

variable "vserver" {default = "${env("PKR_VAR_VCSERVER")}"}
variable "vuser" {default = "${env("PKR_VAR_VCUSER")}"}
variable "vpassword" {default = "${env("PKR_VAR_VCPASSWORD")}"}
variable "vdatacenter" {default = "${env("PKR_VAR_VCDC")}"}
variable "vcluster" {default = "${env("PKR_VAR_VCCLUSTER")}"}
variable "vnetwork" {default = "${env("PKR_VAR_VCNETWORK")}"}
variable "vdatastore" {default = "${env("PKR_VAR_VCDATASTORE")}"}
variable "vmname" {default = "${env("PKR_VAR_VMNAME")}"}
variable "winadminpassword" {default = "${env("PKR_VAR_WINPASSWORD")}"}
variable "isopath" {default = "${env("PKR_VAR_ISOPATH")}"}
variable "vfolder" {default = "${env("PKR_VAR_VFOLDER")}"}

  
  source "vsphere-iso" "windows2019" {
  CPUs                 = 2
  RAM                  = 4096
  RAM_reserve_all      = true
  cluster              = "${var.vcluster}"
  communicator         = "winrm"
  convert_to_template  = "true"
  datacenter           = "${var.vdatacenter}"
  datastore            = "${var.vdatastore}"
  disk_controller_type = ["lsilogic-sas"]
  firmware             = "bios"
  floppy_files         = ["autounattend.xml", "scripts/enable-winrm.ps1", "scripts/install-vm-tools.cmd"]
  folder               = "${var.vfolder}"
  guest_os_type        = "windows9Server64Guest"
  insecure_connection  = "true"
  iso_paths            = ["${var.isopath}", "[] /vmimages/tools-isoimages/windows.iso"]
  network_adapters {
    network      = "${var.vnetwork}"
    network_card = "vmxnet3"
  }
  password = "${var.vpassword}"
  storage {
    disk_size             = 40960
    disk_thin_provisioned = true
  }
  username       = "${var.vuser}"
  vcenter_server = "${var.vserver}"
  vm_name        = "${var.vmname}"
  winrm_password = "${var.winadminpassword}"
  winrm_timeout  = "1h30m"
  winrm_username = "Administrator"
}

build {
  sources = ["source.vsphere-iso.windows2019"]

  #Windows Update Plugin has already been downloaded inside container image
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true",
    ]
    update_limit = 1
  }

  #Inserted reboot as sysprep step fails due to waiting for windows updates to install
  provisioner "windows-restart" {
    restart_timeout = "15m"
  }


  provisioner "windows-shell" {
    inline = ["C:\\windows\\System32\\Sysprep\\sysprep.exe /generalize /shutdown /quiet"]
  }
}