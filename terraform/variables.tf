variable "ssh_enabled" {
    description = "use this in the terraform apply command to enable or disable ssh which will control if ansible and ssh port will open or close"
    type = bool
}