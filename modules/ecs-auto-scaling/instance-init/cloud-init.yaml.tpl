#cloud-config

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
  - "curl -L -f ${instance_script_url} | bash"

write_files:
  - path: /etc/ecs/ecs.config
    content: |
      ECS_CLUSTER=${name}
      ECS_ENABLE_TASK_IAM_ROLE=false

final_message: "The ECS instance is finally up, after $$UPTIME seconds"
