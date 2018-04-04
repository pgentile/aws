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
