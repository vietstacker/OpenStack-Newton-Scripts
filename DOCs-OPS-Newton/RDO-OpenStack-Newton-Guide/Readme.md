# Hướng dẫn cài đặt OpenStack Newton - sử dụng RDO

## Chuẩn bị môi trường

- Hệ điều hành: `CentOS 7.X x86_64`

```sh
[root@ctl1-centos7 ~]# cat /etc/redhat-release
CentOS Linux release 7.2.1511 (Core)

uname -a
Linux ctl1-centos7 3.10.0-327.28.2.el7.x86_64 #1 SMP Wed Aug 3 11:11:39 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
```

- Network

    ```sh 
    - eth0: Managment: 10.10.10.0/24 , no gateway
    - eth1: External:  172.16.69.0/24 , gateway 172.16.69.1
    ```

- Thực thi với tài khoản `root`

### Bước 1: Cài đặt cơ bản

- Thiết lập IP Tĩnh cho các card mạng

    ```sh
    echo "Setup IP  eth0"
    nmcli c modify eth0 ipv4.addresses 10.10.10.30/24
    nmcli c modify eth0 ipv4.method manual

    echo "Setup IP  eth1"
    nmcli c modify eth1 ipv4.addresses 172.16.69.30/24
    nmcli c modify eth1 ipv4.gateway 172.16.69.1
    nmcli c modify eth1 ipv4.dns 8.8.8.8
    nmcli c modify eth1 ipv4.method manual
    ```

- Cấu hình các gói cơ bản

    ```sh
    sudo systemctl disable firewalld
    sudo systemctl stop firewalld
    sudo systemctl disable NetworkManager
    sudo systemctl stop NetworkManager
    sudo systemctl enable network
    sudo systemctl start network
    ```

- Vô hiệu hóa `SELINUX`

```sh
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
```

    
### Bước 2: Khai báo repos

    ```sh
    yum install -y centos-release-openstack-newton
    yum update -y
    ```

### Bước 3: Cài đặt công cụ `packstack` và gói bổ trợ

    ```sh
    sudo yum install -y wget 
    sudo yum install -y openstack-packstack    
    
- Khởi động lại máy trước khi cài đặt

```sh
init 6
```

### Bước 4: cài đặt OpenStack Newton

- Đăng nhập bằng quyền root
- Chạy lệnh dưới để tiến hành cài đặt OpenStack với các option 

```sh
packstack --allinone --provision-demo=n --os-neutron-ovs-bridge-mappings=extnet:br-ex \
    --os-neutron-ovs-bridge-interfaces=br-ex:eth1 --os-neutron-ml2-type-drivers=vxlan,flat
```

- Chờ thời gian cài đặt và thông báo trên màn hình, tùy vào tốc độ mạng của bạn, thời gian có thể từ 30-45 phút.


### Bước 5: Tạo network, router, mở rule 

- Tạo network


- Tạo router


- Tạo private network