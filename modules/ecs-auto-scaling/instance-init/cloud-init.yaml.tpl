#cloud-config
debug:
  verbose: true

timezone: Europe/Paris

package_update: true
package_upgrade: true
package_reboot_if_required: true

packages:
  - awslogs
  - vim
  - zip
  - unzip
  - jq
  - nc
  - traceroute
  - bind-utils
  - lsof

runcmd:
  - "curl -L -v -f ${instance_script_url} -o /tmp/configure-instance.sh"
  - "chmod +x /tmp/configure-instance.sh"
  - "/tmp/configure-instance.sh"

write_files:
  - path: /etc/ecs/ecs.config
    content: |
      ECS_CLUSTER=${name}
      ECS_ENABLE_TASK_IAM_ROLE=false

final_message: "The ECS instance is finally up, after $$UPTIME seconds"
