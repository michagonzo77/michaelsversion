variable "region" {
  description = "The AWS region."
  type = string
}
variable "vpc_id" {
  default = ""
  type = string
}
variable "plume_tags" {
  description = <<EOD
    A set of common tags attached to resources for infrastructure management and
    billing purposes.
    NOTE that the default below isn't valid but just represents the tags that
    must be configured for a successful setup.
  EOD
  default = {
    jira = ""
    owner = "devops"
    costcenter = ""
    environment = ""
    datacenter = ""
    sphere = "flex"
    tld = ""
  }
}
variable "instance_class" {
  description = "The instance class for the cluster nodes."
  # NOTE the default is suitable for dev clouds.
  default = "db.t3.medium"
}
variable "availability_zones" {
  description = "The names of the AWS AZs in which to create cluster nodes."
  type = list(string)
}
variable "component" {
  description = "The name of the component/service for which this cluster is created."
}
variable "tls" {
  description = "If TLS connections should be enabled/disabled for the cluster."
  default = "enabled"
}
variable "parameter_group_family" {
  description = "The family of the documentdb cluster parameter group."
  default = "docdb3.6"
}
variable "engine_version" {
  description = "The documentdb engine version to use for the cluster."
  default = "3.6.0"
}
variable "master_password_length" {
  description = "The length of the master user password."
  default = 32
}
variable "backup_retention_period" {
  default = 7
}
variable "nr_of_instances" {
  description = "The number of cluster instances to launch."
  default = 3
}
variable "master_username" {
  default = "devOpsRootAdmin"
}
variable "subnet_group" {
  description = "The subnet group to use for the cluster. Defaults to sphere-environment-datacenter."
  default = ""
}
variable "create_akamai_app" {
  description = "Enable akamai module to create akamai apps."
  type = bool
  default = true
}
variable "akamai_ldap_users_group_prefix" {
  description = "Users group prefix"
  type = string
  default = ""
}
variable "akamai_app_logo" {
  description = "URL path to application logo"
  type = string
  default = "https://s3.amazonaws.com/bbrw-customer-logos/app_icon_YMwHTNl8Q2uEln9Lv_0ATg1635987976"
}
variable "akamai_ldap_attach_users" {
  description = "List of user which will be attached to IPA group"
  type = list(string)
  default = []
}
variable "akamai_ldap_attach_groups" {
  description = "List of groups which will be attached to IPA group"
  type = list(string)
  default = ["devops-team.all.dbs"]
}
