resource "aws_ssm_parameter" "app_managed_params_store" {
  name  = local.managed_app_ssm_parameter_name
  type  = "String"
  value = var.app.managed_app_ssm_value
}
