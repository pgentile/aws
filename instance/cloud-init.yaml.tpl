#cloud-config
debug:
  verbose: true

preserve_hostname: false
hostname: ${name}

timezone: Europe/Paris

bootcmd:
  # Install required packages for cloud-init APT management
  - 'apt-get update'
  - 'apt-get install -y apt-transport-https dirmngr'

apt:
  preserve_sources_list: True
  sources:
    lylis:
      source: 'deb https://packages.cisofy.com/community/lynis/deb/ $RELEASE main'
      keyid: 'C80E383C3DE9F082E01391A0366C67DE91CA5D5F'
      keyserver: 'keyserver.ubuntu.com'

package_update: true
package_upgrade: true

packages:
  - jq
  - lynis
  - debsecan
  - ack

write_files:
  - path: /etc/apt/apt.conf.d/99disable-translations
    owner: root:root
    content: 'Acquire::Languages "none";'

power_state:
  mode: reboot
  message: Restarting the instance
  condition: True
