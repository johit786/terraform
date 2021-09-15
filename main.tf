resource "azurerm_network_interface" "nic" {
  name = var.nic_name
  location = var.location
  resource_group_name = var.resource_group_name
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name = var.ip_configuration_name
    subnet_id = var.subnet_id
    private_ip_address_allocation = var.private_ip_allocation_type
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.vm_size
  license_type          = var.license_type
  availability_set_id   = var.availability_set_id
  zone = var.zone_id == null ? null : var.zone_id
  custom_data = var.custom_data_content == null ? null : base64encode(var.custom_data_content)
  admin_username = var.vm_admin_name
  admin_password = var.vm_admin_password
  
  boot_diagnostics {
    storage_account_uri = var.diagnostics_storage_account_name
  }
  
  os_disk {
    name              = var.vm_name
    caching           = var.vm_storage_disk_caching
    storage_account_type = var.vm_storage_account_type
  }

  // Abhishek :- Use this "source_image_id" attribute instead
  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.image_version
  }
  
  computer_name            = var.vm_name
  provision_vm_agent       = var.vm_provision_agent
  enable_automatic_updates = var.automatic_updates

   identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_managed_disk" "external_disks" {
  for_each = var.datadisk

  name                 = each.value.external_disk_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  create_option        = each.value.external_disk_create_option
  storage_account_type = each.value.external_storage_account_type
  disk_size_gb         = each.value.external_disk_size
#   disk_encryption_set_id = "test"
#               tags = {
#                 environment = "staging"
#               }
            
}

resource "azurerm_virtual_machine_data_disk_attachment" "external" {
  for_each = var.datadisk

  managed_disk_id    = azurerm_managed_disk.external_disks[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = each.value.lun
  caching            = each.value.external_disk_caching
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface_security_group_association" "interfaceassociation" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
