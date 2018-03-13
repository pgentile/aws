Init AWS
========

Init config with the AWS cli :

```
aws configure
```

This config wil be used by Terraform.


Create infrastructure
=====================

My IP address file:

```
# my_ip.auto.tfvars
my_ip = "MY_IP_ADDRESS"
```

Create infrastructure:

```
terraform apply -auto-approve
```

Destroy infrastructure:

```
terraform destroy -force
```


Connections SSH
===============

See https://blog.octo.com/le-bastion-ssh/

```
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa

ssh -A -o StrictHostKeyChecking=no admin@NAME.eu-west-3.compute.amazonaws.com

# Then, ssh PRIVATE_IP
```

Clés GPG
========

Pour récupérer les clés GPG :

```
apt-get install dirmngr --install-recommends 
```

A faire si blocage par un firewall ou un security group

```
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 
```

Sinon, ouvrir le port suivant :

```
11371/tcp
```

Pour faire :

```
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C36
```


Check my system
===============

SSH config:

```
sudo sshd -T
```

Check the system with Lynis:

```
sudo yum install lynis 
lynis show profiles
lynis show settings
sudo lynis audit system
```
