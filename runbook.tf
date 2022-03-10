
############ automation account  + runbook #############
resource "azurerm_automation_runbook" "vm-start-stop" {
  name                    = "${var.product}-vm-status-change-${var.env}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  log_verbose             = var.env == "prod" ? "false" : "true"
  log_progress            = "false"
  description             = "This is a powershell runbook used to stop and start ${var.product} VMs"
  runbook_type            = "PowerShell"
  content                 = file("${path.module}/vm-start-stop.ps1")

  tags = var.tags
}

################# automation schedule #################
resource "azurerm_automation_schedule" "vm-start-stop" {
  for_each = { for aa_acc_runbook in var.auto_acc_runbooks : aa_acc_runbook.name => aa_acc_runbook }

  name                    = "${var.product}-schedule-${each.value.start_vm == true ? "start" : "stop"}-vm-${replace(each.value.run_time, ":", "-")}-${var.env}"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  frequency               = each.value.frequency
  interval                = each.value.interval
  timezone                = var.timezone
  start_time              = "${formatdate("YYYY-MM-DD", timeadd(timestamp(), "24h"))}T${each.value.start_time}Z"
  description             = "Schedule to ${each.value.start_vm == true ? "start" : "stop"} vm at ${each.value.run_time}"

  depends_on = [
    azurerm_automation_runbook.vm-start-stop
  ]
}

resource "azurerm_automation_job_schedule" "vm-start-stop" {
  for_each = { for aa_acc_runbook in var.auto_acc_runbooks : aa_acc_runbook.name => aa_acc_runbook }

  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  schedule_name           = "${var.product}-schedule-${each.value.start_vm == true ? "start" : "stop"}-vm-${replace(each.value.run_time, ":", "-")}-${var.env}"
  runbook_name            = azurerm_automation_runbook.vm-start-stop.name

  parameters = {
    mi_principal_id = var.mi_principal_id
    vmlist          = var.vm_names
    resourcegroup   = var.resource_group_name
    start_vm        = each.value.start_vm
  }

  depends_on = [
    azurerm_automation_schedule.vm-start-stop
  ]
}
