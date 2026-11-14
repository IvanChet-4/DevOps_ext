variable "each_vm" {
  type = list(object({
    vm_name     = string
    cpu         = number
    ram         = number
    disk_volume = number
  }))
  default = [
    {
      vm_name     = "web-1"
      cpu         = 2
      ram         = 2
      disk_volume = 10
    },
    {
      vm_name     = "web-2"
      cpu         = 2
      ram         = 2
      disk_volume = 10
    }
  ]
}
