locals {
  name_tags = {
    Name = "${var.name}"
  }

  default_resource_name_tags = {
    Name = "default"
  }

  tags                  = "${merge(var.tags, local.name_tags)}"
  default_resource_tags = "${merge(local.tags, local.default_resource_name_tags)}"
}
