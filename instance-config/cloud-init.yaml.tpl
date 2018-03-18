#cloud-config
debug:
  verbose: true

${hostname != "" ? "hostname: ${hostname}": ""} 

timezone: Europe/Paris

bootcmd:
  # Install required packages for cloud-init APT management
  - 'apt-get update'
  - 'apt-get install -y apt-transport-https dirmngr'
  # Docker requires to install its GPG key like that
  - 'curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -'

apt:
  preserve_sources_list: True
  sources:
    lylis:
      source: 'deb https://packages.cisofy.com/community/lynis/deb/ $RELEASE main'
      keyid: 'C80E383C3DE9F082E01391A0366C67DE91CA5D5F'
      keyserver: 'keyserver.ubuntu.com'
    docker:
      source: 'deb [arch=amd64] https://download.docker.com/linux/debian $RELEASE stable'

package_update: true
package_upgrade: true

packages:
  - zip
  - unzip
  - jq
  - lynis
  - debsecan
  - ack
  - docker-ce

write_files:
  - path: /etc/apt/apt.conf.d/99disable-translations
    owner: root:root
    content: 'Acquire::Languages "none";'

  - path: /etc/ssh/sshd_config
    owner: root:root
    content: |
      # Hardened sshd config
      # See https://www.ssh.com/ssh/sshd_config/

      # These params are not the same for an SSH bastion
      AllowTcpForwarding ${ssh_allow_tcp_forwarding}
      AllowAgentForwarding ${ssh_allow_agent_forwarding}

      X11Forwarding no
      AllowStreamLocalForwarding no
      GatewayPorts no
      PermitTunnel no

      # Disabled for now, because sshd rejects all connection attempts
      MaxAuthTries 100

      ClientAliveCountMax 2
      ClientAliveInterval 300
      Compression no
      LogLevel verbose
      MaxSessions 2
      PermitRootLogin no
      TCPKeepAlive no

      UsePAM yes
      PasswordAuthentication no
      ChallengeResponseAuthentication no

      AcceptEnv LANG LC_*

      Subsystem	sftp	/usr/lib/openssh/sftp-server

power_state:
  mode: reboot
  message: Restarting the instance
  condition: True
