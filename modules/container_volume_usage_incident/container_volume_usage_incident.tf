resource "shoreline_notebook" "container_volume_usage_incident" {
  name       = "container_volume_usage_incident"
  data       = file("${path.module}/data/container_volume_usage_incident.json")
  depends_on = [shoreline_action.invoke_disk_usage_alert,shoreline_action.invoke_deployment_checker,shoreline_action.invoke_resize_volume_and_scale_deployment]
}

resource "shoreline_file" "disk_usage_alert" {
  name             = "disk_usage_alert"
  input_file       = "${path.module}/data/disk_usage_alert.sh"
  md5              = filemd5("${path.module}/data/disk_usage_alert.sh")
  description      = "The container has consumed an excessive amount of data, causing the volume usage to exceed its limit."
  destination_path = "/agent/scripts/disk_usage_alert.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "deployment_checker" {
  name             = "deployment_checker"
  input_file       = "${path.module}/data/deployment_checker.sh"
  md5              = filemd5("${path.module}/data/deployment_checker.sh")
  description      = "The container is not set up to auto-scale, and the amount of data being processed is too large for the current container configuration."
  destination_path = "/agent/scripts/deployment_checker.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "resize_volume_and_scale_deployment" {
  name             = "resize_volume_and_scale_deployment"
  input_file       = "${path.module}/data/resize_volume_and_scale_deployment.sh"
  md5              = filemd5("${path.module}/data/resize_volume_and_scale_deployment.sh")
  description      = "Increase the size of the container volume or add a new volume to accommodate additional data."
  destination_path = "/agent/scripts/resize_volume_and_scale_deployment.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_disk_usage_alert" {
  name        = "invoke_disk_usage_alert"
  description = "The container has consumed an excessive amount of data, causing the volume usage to exceed its limit."
  command     = "`chmod +x /agent/scripts/disk_usage_alert.sh && /agent/scripts/disk_usage_alert.sh`"
  params      = ["NAMESPACE","POD_NAME"]
  file_deps   = ["disk_usage_alert"]
  enabled     = true
  depends_on  = [shoreline_file.disk_usage_alert]
}

resource "shoreline_action" "invoke_deployment_checker" {
  name        = "invoke_deployment_checker"
  description = "The container is not set up to auto-scale, and the amount of data being processed is too large for the current container configuration."
  command     = "`chmod +x /agent/scripts/deployment_checker.sh && /agent/scripts/deployment_checker.sh`"
  params      = ["NAMESPACE","DEPLOYMENT_NAME"]
  file_deps   = ["deployment_checker"]
  enabled     = true
  depends_on  = [shoreline_file.deployment_checker]
}

resource "shoreline_action" "invoke_resize_volume_and_scale_deployment" {
  name        = "invoke_resize_volume_and_scale_deployment"
  description = "Increase the size of the container volume or add a new volume to accommodate additional data."
  command     = "`chmod +x /agent/scripts/resize_volume_and_scale_deployment.sh && /agent/scripts/resize_volume_and_scale_deployment.sh`"
  params      = ["DEPLOYMENT_NAME","NEW_VOLUME_SIZE","VOLUME_NAME"]
  file_deps   = ["resize_volume_and_scale_deployment"]
  enabled     = true
  depends_on  = [shoreline_file.resize_volume_and_scale_deployment]
}

