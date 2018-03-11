output "public_subnet_ids" {
  value = ["${module.public_network.subnet_ids}"]
}

output "private_subnet_ids" {
  value = ["${module.private_network.subnet_ids}"]
}

output "database_subnet_ids" {
  value = ["${module.database_network.subnet_ids}"]
}
