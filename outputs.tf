output "public_subnet_ids" {
  value = ["${module.network.public_subnet_ids}"]
}

output "private_subnet_ids" {
  value = ["${module.network.private_subnet_ids}"]
}

output "database_subnet_ids" {
  value = ["${module.network.database_subnet_ids}"]
}
