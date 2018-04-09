CoreOS AWS deployment
=====================

This is an example of a CoreOS deployment on AWS. This config :

* starts an instance of CoreOS
* creates a Cloudwatch log groups for the VPC and the Docker containers
* registers the Docker instance in ECS
* adds the REX-Ray EBS plugin (useful to create Docker volumes on EBS)
* creates an VXLAN network (using CoreOS etcd and Flannel) for Docker 

Init AWS
--------

Init config with the AWS CLI :

```bash
aws configure
```

This config wil be used by Terraform.


Create CoreOS infrastructure
----------------------------

### Install the Config Transpiler Terraform plugin

This Terraform config requires a specific plugin.
You can install the plugin on **MacOS** using the following script :

```bash
./install-terraform-plugins.sh
```

More information:

* https://github.com/coreos/terraform-provider-ct
* https://github.com/coreos/container-linux-config-transpiler
* https://coreos.com/ignition/docs/latest/

### Generate the IP address file

```bash
./get-my-ip.sh
```

This generates a Terraform vars file named `my_ip.auto.tfvars`.
Terraform will use your IP to filter VPC incoming trafic.

### Generate the ectd discovery token

```bash
./init-etcd-discovery-token.sh
```

A Terraform vars file will be created with the token.
Please note that the token can only be used once per deployment.

### Create infrastructure

```bash
terraform apply -auto-approve
```

### Destroy infrastructure

```bash
terraform destroy -force
```
