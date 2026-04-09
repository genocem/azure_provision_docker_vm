resource "azurerm_virtual_network" "dockerVN" {
  name                = "docker-network"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_subnet" "dockerSubnet" {
  name                 = "internal"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dockerVN.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_docker_ip" {
  name                = "docker_public_ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "dockerNetworkInterface" {
  name                = "docker-nic"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dockerSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_docker_ip.id
  }
}

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

resource "azurerm_network_security_group" "docker_security_group" {
  name                = "acceptanceTestSecurityGroup1"
  resource_group_name = var.resource_group_name
  location            = var.location

  # security_rule {
  #   name                       = "AllowSSH"
  #   priority                   = 1001
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "22"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }
  security_rule {
    name                       = "AllowdockerEntry"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "${jsondecode(data.http.my_public_ip.response_body).ip}/32"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}
resource "azurerm_network_security_rule" "ssh_rule" {
  count                       = var.ssh_enabled ? 1 : 0
  name                        = "AllowSSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${jsondecode(data.http.my_public_ip.response_body).ip}/32"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.docker_security_group.name
}
resource "azurerm_network_interface_security_group_association" "docker_interface_securitygroup_association" {
  network_interface_id      = azurerm_network_interface.dockerNetworkInterface.id
  network_security_group_id = azurerm_network_security_group.docker_security_group.id
}

resource "azurerm_linux_virtual_machine" "dockerVM" {
  name                = "docker-machine"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_type
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.dockerNetworkInterface.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.public_key_file_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }


  # this here will try to connect to the machine over ssh
}
resource "null_resource" "ansible_provisioner" {
  count = var.ssh_enabled ? 1 : 0

  depends_on = [azurerm_linux_virtual_machine.dockerVM]

  connection {
    type        = "ssh"
    host        = azurerm_linux_virtual_machine.dockerVM.public_ip_address
    user        = "adminuser"
    private_key = file(var.private_key_file_path)
  }

  provisioner "remote-exec" {
    inline = ["echo 'VM is ready'"]
  }

  provisioner "local-exec" {

    command = <<EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
      -i '${azurerm_linux_virtual_machine.dockerVM.public_ip_address},' \
      ../ansible/playbook.yaml \
      -u adminuser \
      --private-key '${var.private_key_file_path}'
      EOT
  }
}
