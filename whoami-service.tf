resource "aws_ecs_task_definition" "whoami" {
  family                = "whoami"
  container_definitions = "${file("${path.module}/whoami-service.json")}"
  network_mode          = "bridge"
}

resource "aws_ecs_service" "whoami" {
  // We need to wait for load balancer creation before
  // association of the service to the load balancer 
  depends_on = ["aws_lb.load_balancer"]

  name            = "whoami"
  cluster         = "${aws_ecs_cluster.cluster.arn}"
  task_definition = "${aws_ecs_task_definition.whoami.arn}"
  desired_count   = 5

  load_balancer {
    target_group_arn = "${aws_lb_target_group.default.id}"
    container_name   = "whoami"
    container_port   = 80
  }
}
