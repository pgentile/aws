output "subnet_ids" {
  value = "${aws_subnet.this.*.id}"
}

output "route_table_id" {
  value = "${element(coalescelist(aws_route_table.this.*.id, list("")), 0)}"
}
