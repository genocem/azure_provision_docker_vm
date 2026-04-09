
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "res_group_docker" {
  name     = "dockerNew"
  location = "France Central"
}


module "docker_vm" {
  source                = "./modules/docker_vm"
  location              = azurerm_resource_group.res_group_docker.location
  resource_group_name   = azurerm_resource_group.res_group_docker.name
  private_key_file_path = "~/.ssh/id_rsa"
  public_key_file_path  = "~/.ssh/id_rsa.pub"
  vm_type               = "Standard_D2s_v3"
  ssh_enabled           = var.ssh_enabled
}

#for stronger machine we can use Standard_D2s_v3 or smth else
# weak one is Standard_B2als_v2