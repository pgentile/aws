module "ecs_auto_scaling" {
  source = "./modules/ecs-auto-scaling"

  name                        = "ecs"
  key_name                    = "${aws_key_pair.ssh.key_name}"
  subnet_ids                  = ["${module.network.subnet_ids}"]
  associate_public_ip_address = true

  security_group_ids = [
    "${module.security_group.security_group_id}",
  ]

  tags = "${local.platform_tags}"
}

resource "aws_ecs_cluster" "cluster" {
  name = "cluster"
}
