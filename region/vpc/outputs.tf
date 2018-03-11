output "vpc_id" {
  value = "${aws_vpc.this.id}"
}

output "cidr_block" {
  value = "${var.cidr_block}"
}

output "public_subnet_ids" {
  value = ["${module.public_network.subnet_ids}"]
}

output "public_route_table_id" {
  value = "${module.public_network.route_table_id}"
}

output "private_subnet_ids" {
  value = ["${module.private_network.subnet_ids}"]
}

output "private_route_table_id" {
  value = "${module.private_network.route_table_id}"
}

output "database_subnet_ids" {
  value = ["${module.database_network.subnet_ids}"]
}

output "database_route_table_id" {
  value = "${module.database_network.route_table_id}"
}
