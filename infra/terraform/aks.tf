resource "azurerm_virtual_network" "aks_vnet" {
  name                = "vnet-${local.name}"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.aks-store.location
  resource_group_name = azurerm_resource_group.aks-store.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.aks-store.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.240.0.0/16"]
  service_endpoints    = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_container_registry" "aks_registry" {
  count               = local.deploy_azure_container_registry ? 1 : 0
  name                = "acr${local.name}"
  resource_group_name = azurerm_resource_group.aks-store.name
  location            = azurerm_resource_group.aks-store.location
  sku                 = "Premium"
}

resource "null_resource" "get_ip" {
  provisioner "local-exec" {
    command = "curl -4 http://ifconfig.me > myip.txt"
  }
}

resource "azurerm_kubernetes_cluster" "aks_store" {
  name                = "aks-${local.name}"
  location            = azurerm_resource_group.aks-store.location
  resource_group_name = azurerm_resource_group.aks-store.name
  dns_prefix          = "aks-${local.name}"

  default_node_pool {
    name       = "system"
    vm_size    = local.aks_node_pool_vm_size
    node_count = 2
    vnet_subnet_id = azurerm_subnet.aks_subnet.id

    upgrade_settings {
      max_surge = "10%"
    }
  }

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  api_server_access_profile {
    authorized_ip_ranges = ["${local.my_ip}/32"]
  }

  network_profile {
    network_plugin      = "azure"
    network_policy     = "azure"
    dns_service_ip     = "10.2.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "10.2.0.0/24"
  }

  identity {
    type = "SystemAssigned"
  }

  node_os_channel_upgrade   = "SecurityPatch"
  oidc_issuer_enabled       = local.deploy_azure_workload_identity
  workload_identity_enabled = local.deploy_azure_workload_identity

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  dynamic "monitor_metrics" {
    for_each = local.deploy_observability_tools ? [1] : []
    content {
    }
  }

  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.aks_store.id
    msi_auth_for_monitoring_enabled = true
  }

  lifecycle {
    ignore_changes = [
      monitor_metrics,
      azure_policy_enabled,
      microsoft_defender
    ]
  }
}

resource "azurerm_role_assignment" "aks_cluster_admin" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = azurerm_kubernetes_cluster.aks_store.id
}

resource "azurerm_role_assignment" "container_registry" {
  count                            = local.deploy_azure_container_registry ? 1 : 0
  principal_id                     = azurerm_kubernetes_cluster.aks_store.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.aks_registry[0].id
  skip_service_principal_aad_check = true
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = azurerm_resource_group.aks-store.location
  resource_group_name = azurerm_resource_group.aks-store.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "aks_nsg_association" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_application_insights" "aks_store" {
  name                = "appinsights-${local.name}"
  location            = azurerm_resource_group.aks-store.location
  resource_group_name = azurerm_resource_group.aks-store.name
  application_type    = "web"
}
