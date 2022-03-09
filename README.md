# Automation Runbook for Application secret recycling

This module is to setup a Azure Automation Runbook to start or stop VMs within an existing AUtomation Account.


## Example

Below is the standard example setup

```terraform
# =================================================================
# ==========    vm shutdown/start runbook module    ===============
# =================================================================
#  vm shutdown/start runbook module
module "vm_automation" {
  source = "github.com/hmcts/cnp-module-automation-runbook-start-stop-vm"

  product                 = "xyz"
  env                     = "sbox"
  location                = "uksouth"
  automation_account_name = "xyz-sbox-aa"
  auto_acc_runbooks       = [
                              {
                                name        = "vm-on",
                                frequency   = "Day"
                                interval    = 1
                                start_time  = "T06:00:00Z"
                                vm_state_on = true
                              },
                              {
                                name        = "vm-off",
                                frequency   = "Day"
                                interval    = 1
                                start_time  = "T20:00:00Z"
                                vm_state_on = false
                              }
                            ]
  resource_group_id       = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xyz-sbox-rg"
  resource_group_name     = "xyz-sbox-rg"
  vm_names                = join(",", ["xyz-sbox-vm1", "xyz-sbox-vm2"])
  timezone                = "Europe/London"
  script_name             = "/vm-start-stop.ps1"
  tags                    = var.common_tags
}


```

## Requirements   

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 2.97.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_automation_runbook.vm-start-stop](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_schedule.vm-start-stop](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |
| [azurerm_automation_job_schedule.vm-start-stop](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule) | resource |
| [azurerm_user_assigned_identity.automation-account-mi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_role_definition.virtual-machine-control](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_assignment.cvp-auto-acct-mi-role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|

| product | Product name | `string` | n/a | yes |  
| env | Environment | `string` | n/a | yes |  
| location | Location | `string` | uksouth | no |  
| automation_account_name | Automation account name | `string` | n/a | yes |   
| resource_group_id | Resource group id | `string` | n/a | yes |  
| resource_group_name | Resource group name | `string` | n/a | yes |  
| auto_acc_runbooks | Object containaing schedules name, frequency, interval, start time and desired state | `object` | n/a | yes |  
| vm_names | Names of VMs to apply runbook to | `string` | n/a | no |  
| timezone | timezone | `string` | Europe/London | no |  
| script_name | Script name | `string` | /vm-start-stop.ps1 | no |  
| tags | Runbook Tags | `map(string)` | n/a | yes |

## Outputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aa_mi_id | Automation account managed identity id | `string` | n/a | n/a |   