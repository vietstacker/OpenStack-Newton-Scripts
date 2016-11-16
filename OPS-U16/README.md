## OpenStack Newton note

# Mô hình

![Mô hình cài đặt](../images/topo-openstack-newton.png)


# Các bước cài đặt
## Controller node
- Thực hiện các lệnh sau để tải script

	```sh
	apt-get -y update && apt-get -y install git 

	git clone https://github.com/congto/OpenStack-Newton-Scripts.git

	mv /root/OpenStack-Newton-Scripts/OPS-U16/scripts/ /root/

	rm -rf  /root/OpenStack-Newton-Scripts/

	cd scripts

	chmod +x *.sh
	```

- Sửa biến trong file `config.cfg` theo ý muốn. Chỉ cần sửa các biến về địa chỉ IP, Gateway, DNS  sao cho phù hợp với thứ tự card mạng và dải IP thực tế..... Các biến password nên để nguyên.


- Thực thi script dưới để cấu hình IP, khai báo repos của OpenStack cho controller node.
 ```sh
 bash ctl-1-ipadd.sh
 ```
 
- Sau khi thực hiện script trên xong, máy controller sẽ khởi động lại. Đăng nhập với quyền root và thực hiện script tiếp theo.
 ```sh
 su - 
 cd scripts/
 bash ctl-2-prepare.sh
 ```
 
- Thực thi script cài đặt `keystone`

    ```sh
    bash ctl-3.keystone.sh
    ```
    
- Thực thi biến môi trường

    ```sh
    bash admin-openrc
    ```
    
- Thực thi script cài đặt `glance`

    ```sh
    bash ctl-4-glance.sh
    ```
    
- 