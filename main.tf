locals {
  sphere = var.plume_tags.sphere
  environment = var.plume_tags.environment
  datacenter = var.plume_tags.datacenter
}
data "aws_vpc" "this" {
  count = var.vpc_id == "" ? 1 : 0
  filter {
    name = "tag:Name"
    values = ["${local.sphere}-${local.environment}-${local.datacenter}"]
  }
}
resource "aws_security_group" "this" {
  name = "${local.sphere}-${local.environment}-${var.component}-documentdb"
  description = var.plume_tags.jira
  vpc_id = var.vpc_id == "" ? data.aws_vpc.this[0].id : var.vpc_id
  tags = merge(var.plume_tags, {
    Name = "${local.sphere}-${local.environment}-${var.component}-documentdb"
  })
}
resource "aws_docdb_cluster_parameter_group" "this" {
  name        = "${local.sphere}-${local.environment}-${local.datacenter}-${var.component}"
  family      = "docdb3.6"
  description = var.plume_tags.jira
  parameter {
    name  = "tls"
    value = var.tls
  }
}
resource "random_password" "master_password" {
  length = var.master_password_length
  special = false
}
resource "aws_docdb_cluster" "this" {
  cluster_identifier   = "${local.sphere}-${local.environment}-${local.datacenter}-${var.component}"
  engine               = "docdb"
  engine_version       = var.engine_version
  master_username      = var.master_username
  master_password      = random_password.master_password.result
  backup_retention_period = var.backup_retention_period
  db_subnet_group_name = var.subnet_group == "" ? "${local.sphere}-${local.environment}-${local.datacenter}" : var.subnet_group
  deletion_protection = true
  storage_encrypted = true
  availability_zones = var.availability_zones
  skip_final_snapshot     = true
  vpc_security_group_ids = [
    aws_security_group.this.id
  ]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.this.name
  tags = merge(var.plume_tags, {
    component = "docdb"
    role = var.component
  })
}
resource "aws_docdb_cluster_instance" "this" {
  count = var.nr_of_instances
  identifier          = "${local.sphere}-${local.environment}-${local.datacenter}-${var.component}${count.index}"
  instance_class      = var.instance_class
  cluster_identifier = aws_docdb_cluster.this.id
  tags = merge(var.plume_tags, {
    component = "docdb"
    role = var.component
  })
}
module "akamai_ro" {
  count = var.create_akamai_app == true ? 1 : 0
  source = "s3::https://s3-us-west-2.amazonaws.com/plume-global-prod-usw2-eks-artifacts/eks/terraform/modules/akamai-1.2.2-rc2.tgz"
  component_name = var.component
  component_type = "docdb"
  region = var.region
  environment = local.environment
  sphere = local.sphere
  users_group_prefix = var.akamai_ldap_users_group_prefix
  tunnel_internal_host = aws_docdb_cluster.this.reader_endpoint
  tunnel_internal_port = "1-65535"
  origin_port = "27017"
  group_type = "ro"
  app_logo = var.akamai_app_logo
  ticket = var.plume_tags.jira
  attach_users = var.akamai_ldap_attach_users
  attach_groups = var.akamai_ldap_attach_groups
}
module "akamai_rw" {
  count = var.create_akamai_app == true ? 1 : 0
  source = "s3::https://s3-us-west-2.amazonaws.com/plume-global-prod-usw2-eks-artifacts/eks/terraform/modules/akamai-1.2.2-rc2.tgz"
  component_name = var.component
  component_type = "docdb"
  region = var.region
  environment = local.environment
  sphere = local.sphere
  users_group_prefix = var.akamai_ldap_users_group_prefix
  tunnel_internal_host = aws_docdb_cluster.this.reader_endpoint
  tunnel_internal_port = "1-65535"
  origin_port = "27017"
  group_type = "rw"
  app_logo = var.akamai_app_logo
  ticket = var.plume_tags.jira
  attach_users = var.akamai_ldap_attach_users
  attach_groups = var.akamai_ldap_attach_groups
}

