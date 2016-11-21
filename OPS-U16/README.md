# OpenStack Newton note

## Mô hình

![Mô hình cài đặt](../images/topo-openstack-newton.png)




##  Tất cả các node
- Thực hiện các lệnh sau để tải script

	```sh
	apt-get -y update && apt-get -y install git 

	git clone https://github.com/congto/OpenStack-Newton-Scripts.git

	mv /root/OpenStack-Newton-Scripts/OPS-U16/scripts/ /root/

	rm -rf  /root/OpenStack-Newton-Scripts/

	cd scripts

	chmod -R +x *.sh
	```

##  Controller 

- Thực hiện với quyền root

```sh
bash setup01.sh controller
bash setup02.sh controller
bash setup03.sh controller
```

##  Compute1 

- Thực hiện với quyền root

```sh
bash setup01.sh compute1
bash setup02.sh compute1
bash setup03.sh compute1
```

## Tạo network, VM

- Thực hiện trên controller node

```sh
bash create-vm.sh
```

