#Sample: Build Windows2019 vShere Templates

variable "vserver" {default = "${env("VSERVER")}"}
variable "vuser" {default = "${env("VUSER")}"}
variable "vpassword" {default = "${env("VPASSWORD")}"}
variable "vdatacenter" {default = "${env("VDATACENTER")}"}
variable "vcluster" {default = "${env("VCLUSTER")}"}
variable "vnetwork" {default = "${env("VNETWORK")}"}
variable "vdatastore" {default = "${env("VDATASTORE")}"}
variable "vmname" {default = "${env("VMNAME")}"}
variable "winadminpassword" {default = "${env("WINPASSWORD")}"}
variable "isopath" {default = "${env("ISOPATH")}"}

  
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
  folder               = "Tenplates"
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