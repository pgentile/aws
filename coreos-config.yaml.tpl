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
    - "--log-opt awslogs-group=coreos-docker-logs"
    - "--log-opt awslogs-create-group=true"
    # Doesn't work for now...
    # - "--log-opt awslogs-tag={HOSTNAME}/{{ .Name }}"

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

systemd:
  units:
    - name: amazon-ecs-agent.service
      enable: true
      contents: |
        [Unit]
        Description=AWS ECS Agent
        Documentation=https://docs.aws.amazon.com/AmazonECS/latest/developerguide/
        Requires=docker.socket
        After=docker.socket

        [Service]
        Environment=ECS_CLUSTER=${cluster_name}
        Environment=ECS_LOGLEVEL=info
        Environment=ECS_VERSION=latest

        Restart=on-failure
        RestartSec=30
        RestartPreventExitStatus=5

        SyslogIdentifier=ecs-agent

        ExecStartPre=-/bin/mkdir -p /var/ecs-data /etc/ecs
        ExecStartPre=-/usr/bin/touch /etc/ecs/ecs.config
        ExecStartPre=-/usr/bin/docker kill ecs-agent
        ExecStartPre=-/usr/bin/docker rm ecs-agent
        ExecStartPre=/usr/bin/docker pull amazon/amazon-ecs-agent:$${ECS_VERSION}

        ExecStart=/usr/bin/docker run \
          --name ecs-agent \
          --env-file=/etc/ecs/ecs.config \
          --volume=/var/run/docker.sock:/var/run/docker.sock \
          --volume=/var/ecs-data:/data \
          --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
          --volume=/run/docker/execdriver/native:/var/lib/docker/execdriver/native:ro \
          --publish=127.0.0.1:51678:51678 \
          --env=ECS_LOGLEVEL=$${ECS_LOGLEVEL} \
          --env=ECS_DATADIR=/data \
          --env=ECS_CLUSTER=$${ECS_CLUSTER} \
          --env=ECS_ENABLE_TASK_IAM_ROLE=false \
          --env=ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true \
          amazon/amazon-ecs-agent:$${ECS_VERSION}

        [Install]
        WantedBy=multi-user.target
