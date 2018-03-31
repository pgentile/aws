output "ids" {
  description = "Subnet IDs"
  value       = ["${aws_subnet.this.*.id}"]
}

output "route_table_id" {
  description = "Route table ID"
  value       = "${aws_route_table.this.id}"
}

output "network_acl_id" {
  description = "Network ACL ID"
  value       = "${aws_network_acl.this.id}"
}
