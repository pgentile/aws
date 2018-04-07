resource "aws_ecs_cluster" "default" {
  name = "default"
}

resource "aws_ecr_repository" "repository" {
  name = "repository"
}
