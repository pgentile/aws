output "vpc_id" {
  value = "${module.network.vpc_id}"
}

output "cidr_block" {
  value = "${module.network.cidr_block}"
}

output "region" {
  value = "${data.aws_region.this.name}"
}

output "public_subnet_ids" {
  value = ["${module.network.public_subnet_ids}"]
}

output "public_route_table_id" {
  value = "${module.network.public_route_table_id}"
}

output "private_subnet_ids" {
  value = ["${module.network.private_subnet_ids}"]
}

output "private_route_table_id" {
  value = "${module.network.private_route_table_id}"
}

output "database_subnet_ids" {
  value = ["${module.network.database_subnet_ids}"]
}

output "database_route_table_id" {
  value = "${module.network.database_route_table_id}"
}
