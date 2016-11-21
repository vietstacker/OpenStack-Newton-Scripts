## OpenStack Newton note

## Install guide OpenStack Newton - Scripted by VietStack Team 

### Topology 

![Mô hình cài đặt](../images/topo-openstack-newton.png)

### Requirement Hardware

![requirement_hardware.png](../images/requirement_hardware.png)

### Requiement for OS

```
- OS: Ubuntu Server 16.04 64 bit
- CPU support VT
```

### Steps install

####  Controller node

- Download git, scripts install OpenStack Newton 
- Login with account `root` controller node, 

	```sh
	apt-get -y update && apt-get -y install git 

	git clone https://github.com/vietstacker/OpenStack-Newton-Scripts.git

	mv /root/OpenStack-Newton-Scripts/OPS-U16/scripts/ /root/

	rm -rf  /root/OpenStack-Newton-Scripts/

	cd scripts

	chmod -R +x *.sh
	```

##### Run `setup01.sh`
- Can You modify `config.cfg`
- Setup IP, hostname and common package for `controller` node.
- You need type

	```sh
	bash setup01.sh controller
	```


##### Run `setup02.sh` on Controller Node

- Login with account `root` controller node.

	```sh
	cd /scripts
	bash setup02.sh controller
	```


##### Run `setup03.sh` on Controller Node

- Login with account `root` controller node.

	```sh
	bash setup03.sh controller
	```


####  Compute nodes (compute1, compute2, ....)

- Example `compute1` node 

##### Run `setup01.sh`
- Can You modify `config.cfg`
- Setup IP, hostname and common package for `compute1` node.
- You need type

	```sh
	bash setup01.sh compute1
	```


##### Run `setup02.sh` on compute1 Node

- Login with account `root` compute1 node.

	```sh
	cd /scripts
	bash setup02.sh compute1
	```


##### Run `setup03.sh` on compute1 Node

- Login with account `root` compute1 node.

	```sh
	bash setup03.sh compute1
	```


### Create Network, VMs

- Login controller node with `root` account

	```sh
	cd /scripts
	bash  create-vm.sh
	```

# END