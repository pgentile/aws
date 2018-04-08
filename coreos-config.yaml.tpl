etcd:
  # All options get passed as command line flags to etcd.
  # Any information inside curly braces comes from the machine at boot time.

  # multi_region and multi_cloud deployments need to use {PUBLIC_IPV4}
  advertise_client_urls:       "http://{PRIVATE_IPV4}:2379"
  initial_advertise_peer_urls: "http://{PRIVATE_IPV4}:2380"

  # listen on both the official ports and the legacy ports
  # legacy ports can be omitted if your application doesn't depend on them
  listen_client_urls:          "http://0.0.0.0:2379"
  listen_peer_urls:            "http://{PRIVATE_IPV4}:2380"

  # generate a new token for each unique cluster from https://discovery.etcd.io/new?size=1
  # specify the initial size of your cluster with ?size=X
  discovery:                   "${etcd_discovery_token}"

docker:
  flags:
    - "--label env=${env}"
    - "--label platform=${platform}"
    - "--label region=${region}"
    # Container logs to AWS
    - "--log-driver=awslogs"
    - "--log-opt awslogs-region=${region}"
    - "--log-opt awslogs-group=${docker_cloudwatch_log_group}"
    - "--log-opt awslogs-create-group=false"
    # Toujours la galère pour injecter $${COREOS_EC2_HOSTNAME} ...
    - "--log-opt tag=${cluster_name}/{{.Name}}/{{.ID}}"

flannel:
  version: "0.10.0"

storage:
  files:

    # NTP config with AWS NTP server
    # See https://aws.amazon.com/fr/blogs/aws/keeping-time-with-amazon-time-sync-service/
    - path: /etc/systemd/timesyncd.conf
      filesystem: root
      mode: 0644
      contents:
        inline: |
          [Time]
          NTP=169.254.169.123

    # Nice env vars
    - path: /etc/environment
      filesystem: root
      mode: 0644
      contents:
        inline: |
          DOCKER_HIDE_LEGACY_COMMANDS=true

    # Legal banner
    - path: /etc/motd.d/legal-banner.conf
      filesystem: root
      mode: 0644
      contents:
        inline: |
          ############################################################
          #                 Authorized access only!                  # 
          # Disconnect IMMEDIATELY if you are not an authorized user #
          #       All actions will be monitored and recorded.        #
          ############################################################

systemd:
  units:
    # Flannel overlay network config
    - name: flanneld.service
      dropins:
        - name: 50-network-config.conf
          contents: |
            [Service]
            ExecStartPre=/usr/bin/etcdctl set /coreos.com/network/config '{ "Network": "${flannel_cidr_block}", "Backend": { "Type": "vxlan" } }'

    # Allow the Docker config to use metadata from CoreOS ignition
    - name: docker.service
      dropins:
        - name: 10-config-metadata.conf
          contents: |
            [Unit]
            Requires=coreos-metadata.service
            After=coreos-metadata.service

            [Service]
            EnvironmentFile=/run/metadata/coreos

    # Allow Docker volumes to create and manage AWS EBS storage
    - name: docker-plugin-rexray-ebs.service
      enable: true
      contents: |
        [Unit]
        Description=EBS REX-Ray plugin for Docker
        Documentation=http://rexray.readthedocs.io/en/release-0.8.0/user-guide/docker-plugins/#elastic-block-service
        Requires=docker.socket
        After=docker.socket
        PartOf=docker.service

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        SyslogIdentifier=docker-plugin-rexray-ebs

        ExecStart=/usr/bin/docker plugin install --grant-all-permissions rexray/ebs EBS_REGION=${region} REXRAY_FSTYPE=xfs
        
        ExecStop=/usr/bin/docker plugin disable rexray/ebs
        ExecStop=/usr/bin/docker plugin rm rexray/ebs

        [Install]
        WantedBy=multi-user.target

    # Register on the AWS ECS cluster
    - name: ecs-agent.service
      enable: true
      contents: |
        [Unit]
        Description=AWS ECS Agent
        Documentation=https://docs.aws.amazon.com/AmazonECS/latest/developerguide/
        Requires=docker.socket
        After=docker.socket

        [Service]
        Restart=on-failure
        RestartSec=30
        RestartPreventExitStatus=5

        SyslogIdentifier=ecs-agent

        ExecStartPre=-/bin/mkdir -p /var/ecs/data
        ExecStartPre=-/usr/bin/docker kill ecs-agent
        ExecStartPre=-/usr/bin/docker rm ecs-agent
        ExecStartPre=/usr/bin/docker pull amazon/amazon-ecs-agent:latest

        ExecStart=/usr/bin/docker run \
          --name ecs-agent \
          --volume=/var/run/docker.sock:/var/run/docker.sock \
          --volume=/var/ecs/data:/data \
          --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
          --volume=/run/docker/execdriver/native:/var/lib/docker/execdriver/native:ro \
          --publish=127.0.0.1:51678:51678 \
          --env=ECS_LOGLEVEL=info \
          --env=ECS_DATADIR=/data \
          --env=ECS_CLUSTER=${cluster_name} \
          --env=ECS_ENABLE_TASK_IAM_ROLE=false \
          --env=ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true \
          --env=ECS_ENABLE_TASK_ENI=false \
          amazon/amazon-ecs-agent:latest

        [Install]
        WantedBy=multi-user.target
