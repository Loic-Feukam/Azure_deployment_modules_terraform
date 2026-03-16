output "public_ip_address" {
  description = "Adresse IP publique de la vm-public"
  value       = azurerm_public_ip.pip.ip_address
}


output "prive-ip_vm-public" {
  description = "Adresse IP privée dynamique de la vm-public"
  value       = azurerm_network_interface.nic-public.ip_configuration[0].private_ip_address
}


output "ip_vm-prive" {
  description = "Adresse IP privée dynamique de la vm-prive"
  value       = azurerm_network_interface.nic-prive[*].ip_configuration[0].private_ip_address
}
