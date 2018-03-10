Create infrastructure
=====================

My IP address file:

```
# my_ip.tfvars
my_ip = "MY_IP_ADDRESS"
```

Create infrastructure:

```
terraform apply -auto-approve -var-file=my_ip.tfvars 
```

Destroy infrastructure:

```
terraform destroy -force -var-file=my_ip.tfvars 
```

Connections SSH
===============

See https://blog.octo.com/le-bastion-ssh/

```
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa

ssh -A -o StrictHostKeyChecking=no ec2-user@NAME.eu-west-3.compute.amazonaws.com

# Then, ssh PRIVATE_IP
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
