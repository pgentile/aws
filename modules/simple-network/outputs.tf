output "vpc_id" {
  description = "VPC ID"
  value       = "${aws_vpc.this.id}"
}

output "subnet_ids" {
  value = ["${aws_subnet.this.*.id}"]
}
