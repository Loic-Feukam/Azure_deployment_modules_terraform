variable "subscription_id" {}
variable "tenant_id" {}

module "deploy_vm" {
  source = "./modules/Azure_VM"
  
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  resource_group_name = "RG1"
  localisation = "West Europe"
  vnet        = "vnet-test"
  vnet_adress_space = "10.0.0.0/16"
  public-subnet = "10.0.1.0/24"
  prive-subnet  = "10.0.2.0/24"
  vm_name-machine-public = "azure"
  vm_size-machine-public = "Standard_D2pls_v6"
  admin_user_name = "loicmeng"
  ssh_public_key  = "~/.ssh/id_rsa.pub"
  count_vm-prive  = 2
}
