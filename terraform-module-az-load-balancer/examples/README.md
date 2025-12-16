# terraform-module-az-load-balancer examples
The examples here create the following resources:

- Resource group
- Virtual network with 2 subnets, subnet1 and subnet2. Subnet1 has an attached NSG allowing SSH from anywhere at priority 100.

## http_load_balancer
This creates a load balancer accepting HTTP or HTTPS connections on a new public IP and passes the traffic to any VM in the webserver_vmss pooll. The NSG in subnet1 is modified to include rules to allow the traffic to the VMs in the backend pool. The VMs in the backend pool will be probed on port 80.

## sftp_load_balancer
This creates a load balancer accepting SFTP connections on a new private IP in subnet2 and passes the traffic to any VM in the sftp_vmss pooll. The VMs in the backend pool will be probed on port 22. Any outbound connections from the VMs in the pool will originate from the public IP created as part of this module, this allows predictable IP address management for connections to third-parties for file sending and retrieval.
