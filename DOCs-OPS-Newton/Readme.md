# Ghi chép hướng dẫn cài đặt OpenStack Newton - lược dịch theo docs

# 1. Lịch sử tài liệu

# 2. Chuẩn bị
## 2.1. Mô hình

![Mô hình cài đặt](../images/topo-openstack-newton.png)

## 2.2. Yêu cầu cấu hình tối thiểu
- Node CONTROLLER

  ```sh
  CPU: 02 CPU, hỗ trợ công nghệ VT
  RAM: 6GB
  HDD: 40GB
  NICs: 03 NIC
  Hệ điều hành: Ubuntu Server 16.04 - 64 bit
  ```

- Các node COMPUTE1, COMPUTE2

  ```sh
  CPU: 04 CPU, hỗ trợ công nghệ VT
  RAM: 4GB
  HDD: 60GB
  NICs: 03 NIC
  Hệ điều hành: Ubuntu Server 16.04 - 64 bit
  ```

## 2.3 Chú ý khi chuẩn bị


# 3. Cài đặt trên CONTROLLER NODE

## 3.1. Thiết lập IP, hostname
- Login với tài khoản thường và chuyển sang tài khoản root
```sh
su -
```

- Thiết lập địa chỉ IP theo đúng phân hoạch. Sửa file `/etc/network/interfaces` với nội dung như sau:
```sh
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

# MANAGEMENT NETWORK
auto ens3
iface ens3 inet static
address 10.20.0.196/24

# EXTERNAL NETWORK
auto ens4
iface ens4 inet static
address 172.16.69.196/24
gateway 172.16.69.1
dns-nameservers 8.8.8.8

# DATA NETWORK
auto ens5
iface ens5 inet static
address 10.10.20.196/24
```

- Khởi động lại toàn bộ các card mạng sau khi thiết lập IP
```sh
ifdown -a && ifup -a
```

- Kiểm tra lại kết nối tới gateway và internet:
```sh
ping 172.16.69.1 -c 4
PING 172.16.69.1 (172.16.69.1) 56(84) bytes of data.
64 bytes from 172.16.69.1: icmp_seq=1 ttl=64 time=0.601 ms
64 bytes from 172.16.69.1: icmp_seq=2 ttl=64 time=0.341 ms
64 bytes from 172.16.69.1: icmp_seq=3 ttl=64 time=0.348 ms
64 bytes from 172.16.69.1: icmp_seq=4 ttl=64 time=0.386 ms

--- 172.16.69.1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 2997ms
rtt min/avg/max/mdev = 0.341/0.419/0.601/0.106 ms
```
```sh
ping google.com -c 4
PING google.com (203.162.236.211) 56(84) bytes of data.
64 bytes from static.vnpt.vn (203.162.236.211): icmp_seq=1 ttl=58 time=0.658 ms
64 bytes from static.vnpt.vn (203.162.236.211): icmp_seq=2 ttl=58 time=0.575 ms
64 bytes from static.vnpt.vn (203.162.236.211): icmp_seq=3 ttl=58 time=0.580 ms
64 bytes from static.vnpt.vn (203.162.236.211): icmp_seq=4 ttl=58 time=0.653 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 2999ms
rtt min/avg/max/mdev = 0.575/0.616/0.658/0.046 ms
```

- Cấu hình hostname. Sửa file `/etc/hostname`, thực hiện lệnh sau:
```sh
echo "controller" > /etc/hostname
```

- Cập nhật lại file `/etc/hosts` để phân giải từ IP sang hostname và ngược lại với nội dung như sau:
```sh
127.0.0.1   localhost
127.0.1.1   controller
10.20.0.196 controller
10.20.0.197 compute1
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

- *Chú ý:* Không xóa hai dòng cấu hình với địa chỉ `127.0.0.1`

- Cập nhật các gói cho hệ thống
```sh
apt-get update
```

## 3.2. Cài đặt NTP
- Cài đặt gói chrony (tương đương với gói NTP)
```
apt-get install chrony
```

- Cấu hình chrony. Mở file `/etc/chrony/chrony.conf`. Tìm tới dòng `pool 2.debian.pool.ntp.org offline iburst`, comment lại dòng đó rồi chỉnh sửa lại như sau:
```sh
#pool 2.debian.pool.ntp.org offline iburst
server 0.asia.pool.ntp.org iburst
server 1.asia.pool.ntp.org iburst
server 2.asia.pool.ntp.org iburst
server 3.asia.pool.ntp.org iburst
```

- Khởi động lại dịch vụ NTP
```sh
service chrony restart
```

- Kiểm tra lại hoạt động của NTP: `chronyc sources`
```sh
chronyc sources
210 Number of sources = 3
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^- time1.isu.net.sa              1  10   377   726  -1525us[-1798us] +/-  201ms
^- ntp.nic.kz                    1  10   377   751  +3533us[+3261us] +/-  241ms
^* time.vng.vn                   2  10   377   491  -1524us[-1804us] +/-   75ms
```


## 3.3. OpenStack packages
- Khai báo repos cho OpenStack Newton

```sh
apt-get install software-properties-common
add-apt-repository cloud-archive:newton
```

- Update sau khi khai báo repos cho `OpenStack Newton`
```sh
apt-get update && apt-get dist-upgrade -y
```

- Cài đặt các gói openstack-client
```sh
apt-get install python-openstackclient -y
```

## 3.4. SQL database
### Cài đặt và cấu hình MariaDB
- Cài đặt MariaDB
```sh
apt-get install mariadb-server python-pymysql
```

- Cấu hình MariaDB. Tạo file: `vi /etc/mysql/mariadb.conf.d/99-openstack.cnf` với nội dung như sau:
```sh
[mysqld]
bind-address = 10.20.0.196

default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
```

 *Chú ý:* Giá trị `bind-address` thiết lập với địa chỉ dải `MANAGEMENT` của máy `CONTROLLER`, ở đây là `10.20.0.196`.

- Khởi động lại dịch vụ database:
```sh
service mysql restart
```

- Cấu hình password cho tài khoản `root`:
```sh
mysql_secure_installation
```
Hệ thống sẽ hỏi để cập nhật tài khoản `root` với password mới, thực hiện như sau:
```sh
Enter current password for root (enter for none): <enter>
Set root password? [Y/n] y
New password: Welcome123
Re-enter new password: Welcome123
Remove anonymous users? [Y/n] y
Disallow root login remotely? [Y/n] y
Remove test database and access to it? [Y/n] y
Reload privilege tables now? [Y/n] y
```

## 3.5. Message queue
- Cài đặt RabbitMQ:
```sh
apt-get install rabbitmq-server
```
- Tạo user `openstack`:
```sh
rabbitmqctl add_user openstack Welcome123
```
- Cấu hình cho phép quyền cấu hình, ghi và đọc cho user `openstack`:
```sh
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
```

## 3.6. Memcached
- Cài đặt gói cần thiết:
```sh
apt-get install memcached python-memcache
```
- Cấu hình memcached, sửa file `/etc/memcached.conf`, tìm tới dòng `-l 127.0.0.1` và sửa lại như sau:
```sh
-l 10.20.0.196
```
- Khởi động lại dịch vụ memcached:
```sh
service memcached restart
```


## 3.7. Cài đặt và cấu hình `Keystone`
### Chuẩn bị cho cài đặt `Keystone`
- Tạo database `keystone`:
 - Truy cập database client:
 ```sh
 mysql -u root -pWelcome123
 ```

 - Tạo database:
 ```sh
 CREATE DATABASE keystone;
 GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'Welcome123';
 GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'Welcome123';
 EXIT;
 ```

### Cài đặt và cấu hình các thành phần của `Keystone`
- Cài đặt các gói của `keystone` trên node `CONTROLLER`:
```sh
apt-get install keystone
```

- Sửa file cấu hình của `keystone`:
 - Tạo file backup cho file cấu hình gốc của `keystone` để khôi phục khi cần thiết:
 ```sh
 cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.orig
 cat /etc/keystone/keystone.conf.orig | egrep -v '^#|^$' > /etc/keystone/keystone.conf
 ```

 - Mở file cấu hình keystone: `vi /etc/keystone/keystone.conf`

 - Tìm tới section `[database]` và chỉnh sửa như sau:
  ```sh
  [database]
  connection = mysql+pymysql://keystone:Welcome123@controller/keystone
  ```

 - Tìm tới section `[token]` và chỉnh sửa như sau:
  ```sh
  [token]
  provider = fernet
  ```

- Cập nhật cấu vào trong database `keystone`:
```sh
su -s /bin/sh -c "keystone-manage db_sync" keystone
```

- Tạo repos Fernet key:
```sh
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
```

- Tạo endpoints cho `keystone`:
```sh
keystone-manage bootstrap --bootstrap-password Welcome123 \
--bootstrap-admin-url http://controller:35357/v3/ \
--bootstrap-internal-url http://controller:35357/v3/ \
--bootstrap-public-url http://controller:5000/v3/ \
--bootstrap-region-id RegionOne
```

- Cấu hình Apache HTTP server:
```sh
echo "ServerName controller" >> /etc/apache2/apache2.conf
```

- Kết thúc tiến trình cài đặt:
 - Khởi động lại dịch vụ Apache và xóa SQLite database mặc định của keystone:
 ```sh
 service apache2 restart
 rm -f /var/lib/keystone/keystone.db
 ```

 - Thiết lập biến môi trường cho tài khoản quản trị:
 ```sh
 export OS_USERNAME=admin
 export OS_PASSWORD=Welcome123
 export OS_PROJECT_NAME=admin
 export OS_USER_DOMAIN_NAME=Default
 export OS_PROJECT_DOMAIN_NAME=Default
 export OS_AUTH_URL=http://controller:35357/v3
 export OS_IDENTITY_API_VERSION=3
 ```

### Tạo domain, projects, users và roles
- Tạo project `service`:
```sh
openstack project create --domain default \
  --description "Service Project" service
```

- Tạo project và user `demo` để thực hiện các tác vụ thông thường (không phải quản trị viên):
 - Tạo project `demo`:
 ```sh
 openstack project create --domain default \
   --description "Demo Project" demo
 ```

 - Tạo user `demo`:
 ```sh
 openstack user create demo --domain default --password Welcome123
 ```

 - Tạo role `user`:
 ```sh
 openstack role create user
 ```

 - Gán role `user` cho người dùng `demo` trên project `demo`:
 ```sh
 openstack role add --project demo --user demo user
 ```

### Xác nhận quá trình cài đặt
- Xóa bỏ mô hình token xác thực tạm thời bằng cách chỉnh sửa file `/etc/keystone/keystone-paste.ini`. Tìm tới các section `[pipeline:public_api]`, `[pipeline:admin_api]`, `[pipeline:api_v3]` và chỉnh sửa lại như sau:
```sh
[pipeline:public_api]
pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension public_service

[pipeline:admin_api]
pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension s3_extension admin_service

[pipeline:api_v3]
pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize request_id build_auth_context token_auth json_body ec2_extension_v3 s3_extension service_v3
```

- Bỏ thiết lập biến môi trường `OS_URL`:
```sh
unset OS_URL
```

- Xin cấp token với quyền hạn của user `admin`:
```sh
openstack --os-auth-url http://controller:35357/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name admin --os-username admin token issue
+------------+----------------------------------------------------------------------------------------------------------------------+
| Field      | Value                                                                                                                |
+------------+----------------------------------------------------------------------------------------------------------------------+
| expires    | 2016-10-24 13:38:35+00:00                                                                                            |
| id         | gAAAAABYDgDL3zlqpCS5daR8cuGfURCQgwGHieTfeB9jqbAEFAFF73FmSHXuTzAVbZz95GWZe7AphrrJ06fwRpcxV4dy9                        |
|            | -SkrRstB7vMwe90Qb0mdrKllGfob7zYQwqj2i-gnV6NXJdDkby05vkzx-GxQLDFHWNNh01990MV3d1sXHluPgNCOtQ                           |
| project_id | b7fee5a2930e45bba4538372bfaa86e9                                                                                     |
| user_id    | c8c74ce150824b85804f02d9c2e01c30                                                                                     |
+------------+----------------------------------------------------------------------------------------------------------------------+
```

- Xin cấp token với quyền hạn của user `demo`:

```sh
openstack --os-auth-url http://controller:5000/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name demo --os-username demo token issue
 +------------+----------------------------------------------------------------------------------------------------------------------+
 | Field      | Value                                                                                                                |
 +------------+----------------------------------------------------------------------------------------------------------------------+
 | expires    | 2016-10-24 13:39:37+00:00                                                                                            |
 | id         | gAAAAABYDgEJR_H2hZeawN_O1tCS2-ZT0JV6siEUc9SB41bytbNxqTa_qITLUK2h3uEFaKrr-                                            |
 |            | eh06uDN2bYKy6XnsSBWPpgXt6oX4cfj0VgVYtKpY3bc0_xlFlqqs76U1JNUGm3K-_1GZuTJIL3b-3lJ2-eWpRGqRmJnhdTub1VoSHOFCL1uWAc       |
 | project_id | 5611861795a845eb8ba14b96fc6597f1                                                                                     |
 | user_id    | 7adb9cc387604b8bb1fc45e444a5dda3                                                                                     |
 +------------+----------------------------------------------------------------------------------------------------------------------+
```

### Tạo script thiết lập biến môi trường
- Tạo file biến môi trường cho project và user `admin`: `vi admin-openrc`. Nội dung file như sau:
```sh
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=Welcome123
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

- Tạo file biến môi trường cho project và user `demo`: `vi demo-openrc`. Nội dung file như sau:
```sh
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=Welcome123
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

- Sử dụng script:
 - Thiết lập biến môi trường:
 ```sh
 source admin-openrc
 ```

 - Xin cấp token:
 ```sh
 openstack token issue
 +------------+----------------------------------------------------------------------------------------------------------------------+
| Field      | Value                                                                                                                |
+------------+----------------------------------------------------------------------------------------------------------------------+
| expires    | 2016-10-24 13:49:50+00:00                                                                                            |
| id         | gAAAAABYDgNu5HO2Xeez6XganJX7mjk5IxaN748Lqh1GHQHQYxdoPbZ9ELF_7Bj14_IX9zHbQV8n2vE36YJ_sd5w7pluK8_4ZDEIKjbR1kqMBqZ4nAgq |
|            | vln6BN5G47FHjdhzr7feYJ0uJ00llcaTF0cXT2-vdjVFL5I8qPIeo_a54m_7lyxVMRU                                                  |
| project_id | b7fee5a2930e45bba4538372bfaa86e9                                                                                     |
| user_id    | c8c74ce150824b85804f02d9c2e01c30                                                                                     |
+------------+----------------------------------------------------------------------------------------------------------------------+
 ```

## 3.8. Cài đặt và cấu hình `Glance`
### Chuẩn bị cho cài đặt `Glance`
- Tạo database `glance`:
 - Truy cập database client:
 ```sh
 mysql -u root -pWelcome123
 ```

 - Tạo database `glance`:
 ```sh
 CREATE DATABASE glance;
 GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'Welcome123';
 GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'Welcome123';
  EXIT;
 ```

- Thiết lập biến môi trường:
```sh
source admin-openrc
```

- Tạo service user `glance`:
 - Tạo user `glance`:
 ```sh
 openstack user create glance --domain default --password Welcome123
 ```

 - Gán `admin` role cho user `glance` trên project `service`:
 ```sh
 openstack role add --project service --user glance admin
 ```

 - Tạo dịch vụ `glance`:
 ```sh
 openstack service create --name glance --description "OpenStack Image service" image
 ```

- Tạo API endpoints cho Image service:
```sh
openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292
```

### Cài đặt và cấu hình các thành phần
- Cài đặt gói:
```sh
apt-get install glance
```

- Cấu hình glance:
 - Lưu lại các file cấu hình gốc của glance:
 ```sh
 cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.orig
 cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.orig
 cat /etc/glance/glance-api.conf.orig | egrep -v '^#|^$' > /etc/glance/glance-api.conf
 cat /etc/glance/glance-registry.conf.orig | egrep -v '^#|^$' > /etc/glance/glance-registry.conf
 ```

 - Chỉnh sửa file `/etc/glance/glance-api.conf` theo các bước sau:
     - Tìm tới section `[database]` sửa lại như sau:
     ```sh
     connection = mysql+pymysql://glance:Welcome123@controller/glance
     ```
     - Tìm tới các section `[keystone_authtoken]` và `[paste_deploy]` chỉnh sửa lại như sau:
     ```sh
     [keystone_authtoken]
     auth_uri = http://controller:5000
     auth_url = http://controller:35357
     memcached_servers = controller:11211
     auth_type = password
     project_domain_name = default
     user_domain_name = default
     project_name = service
     username = glance
     password = Welcome123     

     [paste_deploy]
     flavor = keystone
     ```
     Chú ý comment lại tất cả các dòng cấu hình khác của section `[keystone_authtoken]`.
     - Tìm tới section `[glance_store]`, chỉnh sửa lại như sau:
     ```sh
     [glance_store]
     stores = file,http
     default_store = file
     filesystem_store_datadir = /var/lib/glance/images/
     ```


 - Chỉnh sửa file `/etc/glance/glance-registry.conf` theo các bước sau:
     - Tìm tới section `[database]` sửa lại như sau:
     ```sh
     connection = mysql+pymysql://glance:Welcome123@controller/glance
     ```
     - Tìm tới các section `[keystone_authtoken]` và `[paste_deploy]` chỉnh sửa lại như sau:
     ```sh
     [keystone_authtoken]
     auth_uri = http://controller:5000
     auth_url = http://controller:35357
     memcached_servers = controller:11211
     auth_type = password
     project_domain_name = default
     user_domain_name = default
     project_name = service
     username = glance
     password = Welcome123     

     [paste_deploy]
     flavor = keystone
     ```
     Chú ý comment lại tất cả các dòng cấu hình khác của section `[keystone_authtoken]`.

- Đồng bộ cấu hình của glance vào database:
 ```sh
 su -s /bin/sh -c "glance-manage db_sync" glance
 ```

- Khởi động lại các dịch vụ cần thiết:
 ```sh
 service glance-registry restart
 service glance-api restart
 ```

### Xác nhận việc cài đặt
- Thiết lập biến môi trường:
```sh
source admin-openrc
```
- Tải image về để kiểm tra:
```sh
 wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
```
- Tải image lên Image service:
```sh
openstack image create "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public
```
- Xác nhận việc tải lên thành công:
```sh
openstack image list
+--------------------------------------+--------+--------+
| ID                                   | Name   | Status |
+--------------------------------------+--------+--------+
| 987892a2-f6b7-45ee-84bf-1784ee67af18 | cirros | active |
+--------------------------------------+--------+--------+
```

## 3.9. Cài đặt và cấu hình `Nova`
### Chuẩn bị cho cài đặt `Nova`
- Tạo database `nova`:
 - Truy cập database client:
 ```sh
 mysql -u root -pWelcome123
 ```

 - Tạo 2 database `nova_api` và `nova`:
 ```sh
 CREATE DATABASE nova_api;
 CREATE DATABASE nova;

 GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'Welcome123';
 GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'Welcome123';
 GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'Welcome123';
 GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'Welcome123';

 EXIT;
 ```

- Thiết lập biến môi trường:
```sh
source admin-openrc
```

- Tạo user định danh cho dịch vụ `nova`:
 - Tạo user `nova`:
 ```sh
 openstack user create nova --domain default  --password Welcome123
 ```
 - Gán role `admin` cho user `nova` trên project service:
 ```sh
 openstack role add --project service --user nova admin
 ```
 - Tạo dịch vụ `nova`:
 ```sh
 openstack service create --name nova --description "OpenStack Compute" compute
 ```

- Tạo endpoints truy cập nova:
```sh
openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1/%\(tenant_id\)s
```

### Cài đặt gói và cấu hình cho `Nova`
- Cài đặt các gói cần thiết:
```sh
apt-get install nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler
```
- Cấu hình nova.
 - Lưu lại cấu hình gốc của `nova`:
 ```sh
 cp /etc/nova/nova.conf /etc/nova/nova.conf.orig
 cat /etc/nova/nova.conf.orig | egrep -v '^#|^$' > /etc/nova/nova.conf
 ```
 - Chỉnh sửa file `/etc/nova/nova.conf` theo các bước sau:
     - Trong section `[DEFAULT]`, tìm tới những dòng sau và sửa lại như bên dưới:
     ```sh
     [DEFAULT]
     enabled_apis = osapi_compute,metadata
     transport_url = rabbit://openstack:Welcome123@controller
     auth_strategy = keystone
     my_ip = 10.20.0.196
     use_neutron = True
     firewall_driver = nova.virt.firewall.NoopFirewallDriver
     ```
     Chú ý: xóa dòng cấu hình tùy chọn `log-dir` trong section `[DEFAULT]` để tránh gây lỗi.    

     - Trong các section `[api_database]` và `[database]` chỉnh sửa lại như sau:
     ```sh
     [api_database]
     connection = mysql+pymysql://nova:Welcome123@controller/nova_api   

     [database]
     connection = mysql+pymysql://nova:Welcome123@controller/nova
     ```    

     - Trong section `[keystone_authtoken]` chỉnh sửa lại như sau:
     ```sh
     [keystone_authtoken]
     auth_uri = http://controller:5000
     auth_url = http://controller:35357
     memcached_servers = controller:11211
     auth_type = password
     project_domain_name = default
     user_domain_name = default
     project_name = service
     username = nova
     password = Welcome123
     ```    

     - Tìm tới section `[vnc]` và chỉnh sửa lại như sau:
     ```sh
     [vnc]
     vncserver_listen = $my_ip
     vncserver_proxyclient_address = $my_ip
     ```    

     - Tìm tới section `[glance]` và chỉnh sửa lại như sau:
     ```sh
     [glance]
     api_servers = http://controller:9292
     ```    

     - Tìm tới section `[oslo_concurrency]` và chỉnh sửa lại như sau:
     ```sh
     [oslo_concurrency]
     lock_path = /var/lib/nova/tmp
     ```

     - Thêm section `[neutron]` với nội dung như sau:
     ```sh
     [neutron]
     url = http://controller:9696
     auth_url = http://controller:35357
     auth_type = password
     project_domain_name = default
     user_domain_name = default
     region_name = RegionOne
     project_name = service
     username = neutron
     password = Welcome123
     service_metadata_proxy = True
     metadata_proxy_shared_secret = Welcome123
     ```

- Cập nhật cấu hình vào database:
```sh
su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage db sync" nova
```

### Kết thúc cài đặt `Nova`
- Khởi động lại các dịch vụ cần thiết:
```sh
service nova-api restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
```
- Kiểm tra các dịch vụ của nova:
```sh
source admin-openrc
openstack compute service list
+----+------------------+------------+----------+---------+-------+----------------------------+
| ID | Binary           | Host       | Zone     | Status  | State | Updated At                 |
+----+------------------+------------+----------+---------+-------+----------------------------+
|  4 | nova-consoleauth | controller | internal | enabled | up    | 2016-10-25T03:34:36.000000 |
|  5 | nova-scheduler   | controller | internal | enabled | up    | 2016-10-25T03:34:36.000000 |
|  6 | nova-conductor   | controller | internal | enabled | up    | 2016-10-25T03:34:37.000000 |
|  8 | nova-compute     | compute1   | nova     | enabled | up    | 2016-10-25T03:34:41.000000 |
+----+------------------+------------+----------+---------+-------+----------------------------+
```

## 3.10. Cài đặt và cấu hình `Neutron`

### Chuẩn bị cho cài đặt `Neutron`
- Tạo database `neutron`:
 - Truy cập database client:
 ```sh
 mysql -u root -pWelcome123
 ```

 - Tạo `neutron` database:
 ```sh
 CREATE DATABASE neutron;

 GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'Welcome123';
 GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'Welcome123';

 EXIT;
 ```
- Thiết lập biến môi trường:
```sh
source admin-openrc
```
- Tạo service user `neutron` định danh cho dịch vụ networking:
 - Tạo user `neutron`:
 ```sh
 openstack user create neutron --domain default --password Welcome123
 ```

 - Gán role `admin` cho user `neutron` trên project `service`:
 ```sh
 openstack role add --project service --user neutron admin
 ```

 - Tạo dịch vụ `neutron`:
 ```sh
 openstack service create --name neutron --description "OpenStack Networking" network
 ```

- Tạo API endpoint truy cập `Neutron`:
```sh
openstack endpoint create --region RegionOne network public http://controller:9696
openstack endpoint create --region RegionOne network internal http://controller:9696
openstack endpoint create --region RegionOne network admin http://controller:9696
```

### Cài đặt và cấu hình `Neutron`
- Cài đặt các gói cần thiết:
```sh
apt-get install neutron-server neutron-plugin-ml2 \
neutron-openvswitch-agent neutron-l3-agent neutron-dhcp-agent \
neutron-metadata-agent
```

- Cấu hình `neutron server`:
 - Lưu lại cấu hình gốc:
 ```sh
 cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.orig
 cat /etc/neutron/neutron.conf.orig | egrep -v '^#|^$' > /etc/neutron/neutron.conf
 ```
 - Chỉnh sửa file `/etc/neutron/neutron.conf` theo các bước sau:
     - Trong section `[database]` chỉnh sửa lại như sau:
     ```sh
     [database]
     connection = mysql+pymysql://neutron:Welcome123@controller/neutron
     ```    

     - Trong section `[DEFAULT]`, tìm đến các tùy chọn sau và chỉnh sửa lại như dưới:
     ```sh
     [DEFAULT]
     core_plugin = ml2
     service_plugins = router
     allow_overlapping_ips = True
     rpc_backend = rabbit
     auth_strategy = keystone
     notify_nova_on_port_status_changes = True
     notify_nova_on_port_data_changes = True
     ```    

     - Trong section `[oslo_messaging_rabbit]`, chỉnh sửa lại như bên dưới:
     ```sh
     [oslo_messaging_rabbit]
     rabbit_host = controller
     rabbit_userid = openstack
     rabbit_password = Welcome123
     ```    

     - Trong section `[keystone_authtoken]`, chỉnh sửa lại như bên dưới:
     ```sh
     [keystone_authtoken]
     auth_uri = http://controller:5000
     auth_url = http://controller:35357
     memcached_servers = controller:11211
     auth_type = password
     project_domain_name = default
     user_domain_name = default
     project_name = service
     username = neutron
     password = Welcome123
     ```
     Chú ý: comment hoặc xóa bỏ mọi tùy chọn khác trong section `[keystone_authtoken]` nếu có.  

     - Trong section `[nova]`, chỉnh sửa lại như sau:
     ```sh
     [nova]
     auth_url = http://controller:35357
     auth_type = password
     project_domain_name = default
     user_domain_name = default
     region_name = RegionOne
     project_name = service
     username = nova
     password = Welcome123
     ```

- Cấu hình `Modular Layer 2 plugin`:
 - Lưu lại cấu hình gốc:
 ```sh
 cp /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.orig
 cat /etc/neutron/plugins/ml2/ml2_conf.ini.orig | egrep -v '^#|^$' > /etc/neutron/plugins/ml2/ml2_conf.ini
 ```
 - Chỉnh sửa file `/etc/neutron/plugins/ml2/ml2_conf.ini` theo các bước sau:
     - Trong section `[ml2]`, chỉnh sửa lại các tùy chọn như sau:
     ```sh
     [ml2]
     type_drivers = flat,vlan,vxlan
     tenant_network_types = vxlan
     mechanism_drivers = openvswitch,l2population
     extension_drivers = port_security
     ```    

     - Trong section `[ml2_type_flat]`, chỉnh sửa lại như sau:
     ```sh
     [ml2_type_flat]
     flat_networks = provider
     ```    

     - Trong section `[ml2_type_vxlan]`, chỉnh sửa lại như sau:
     ```sh
     [ml2_type_vxlan]
     vni_ranges = 1:1000
     ```    

     - Trong section `[securitygroup]`, chỉnh sửa lại như sau:
     ```sh
     [securitygroup]
     enable_ipset = True
     ```

- Cấu hình `Open vSwitch agent`:
 - Lưu lại cấu hình gốc:
 ```sh
 cp /etc/neutron/plugins/ml2/openvswitch_agent.ini /etc/neutron/plugins/ml2/openvswitch_agent.ini.orig
 cat /etc/neutron/plugins/ml2/openvswitch_agent.ini.orig | egrep -v '^#|^$' > /etc/neutron/plugins/ml2/openvswitch_agent.ini
 ```
 - Chỉnh sửa lại file `/etc/neutron/plugins/ml2/openvswitch_agent.ini` theo các bước sau:
     - Tìm tới section `[agent]`, chỉnh sửa lại như sau:
     ```sh
     [agent]
     tunnel_types = vxlan
     l2_population = True
     ```
     - Tìm tới section `[ovs]`, chỉnh sửa lại như sau:
     ```sh
     [ovs]
     local_ip = 10.10.20.196
     bridge_mappings = provider:br-ex
     ```
      Chú ý giá trị tùy chọn `local_ip` đặt bằng địa chỉ IP của card thuộc dải `DATA NETWORK`.  

     - Tìm tới section `[securitygroup]`, chỉnh sửa lại như sau:
     ```sh
     [securitygroup]
     firewall_driver = iptables_hybrid
     ```

- Cấu hình `l3 agent`:
 - Lưu lại cấu hình gốc:
 ```sh
 cp /etc/neutron/l3_agent.ini /etc/neutron/l3_agent.ini.orig
 cat /etc/neutron/l3_agent.ini.orig | egrep -v '^#|^$' > /etc/neutron/l3_agent.ini
 ```
 - Chỉnh sửa file `/etc/neutron/l3_agent.ini`. Trong section `[DEFAULT]`, chỉnh sửa lại như sau:
 ```sh
 [DEFAULT]
 interface_driver = openvswitch
 external_network_bridge =
 ```

- Cấu hình `DHCP agent`:
 - Lưu lại cấu hình gốc:
 ```sh
 cp /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.orig
 cat /etc/neutron/dhcp_agent.ini.orig | egrep -v '^#|^$' > /etc/neutron/dhcp_agent.ini
 ```
 - Chỉnh sửa file `/etc/neutron/dhcp_agent.ini`. Trong section `[DEFAULT]`, chỉnh sửa lại như sau:
 ```sh
 [DEFAULT]
 interface_driver = openvswitch
 dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
 enable_isolated_metadata = True
 ```

- Cấu hình `Metadata agent`:
 - Lưu lại cấu hình gốc của `metadata agent`:
 ```sh
 cp /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini.orig
 cat /etc/neutron/metadata_agent.ini.orig | egrep -v '^#|^$' > /etc/neutron/metadata_agent.ini
 ```

 - Chỉnh sửa file `/etc/neutron/metadata_agent.ini`, trong section `[DEFAULT]` tìm tới những dòng sau và chỉnh sửa lại như bên dưới:
 ```sh
 [DEFAULT]
 nova_metadata_ip = controller
 metadata_proxy_shared_secret = Welcome123
 ```

### Xác nhận quá trình cài đặt `Neutron`
- Cập nhật cấu hình neutron vào database:
```sh
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
--config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
```

- Tạo external bridge `br-ex`:
 - Tạo external bridge `br-ex` kết nối với external interface `ens4`:
 ```sh
 ovs-vsctl add-br br-ex
 ovs-vsctl add-port br-ex ens4
 ifconfig ens4 0
 ifconfig br-ex 172.16.69.196/24
 route add default gw 172.16.69.1
 ```

 - Chỉnh sửa lại cấu hình của `br-ex` và `ens4` vào file `/etc/network/interfaces` như sau:
 ```sh
 # EXTERNAL NETWORK
 auto br-ex
 iface br-ex inet static
 address 172.16.69.196/24
 gateway 172.16.69.1
 dns-nameservers 8.8.8.8

 auto ens4
 iface ens4 inet manual
    up ifconfig $IFACE 0.0.0.0 up
    up ip link set $IFACE promisc on
    down ip link set $IFACE promisc off
    down ifconfig $IFACE down
 ```

- Khởi động lại các dịch vụ cần thiết:
```sh
service nova-api restart
service neutron-server restart
service neutron-openvswitch-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart
service neutron-l3-agent restart
```

- Kiểm tra lại các thành phần của neutron:
```sh
source admin-openrc
neutron agent-list
+----------------------+--------------------+------------+-------------------+-------+----------------+------------------------+
| id                   | agent_type         | host       | availability_zone | alive | admin_state_up | binary                 |
+----------------------+--------------------+------------+-------------------+-------+----------------+------------------------+
| 12bfe033-d9d6-4f37-a | Open vSwitch agent | compute1   |                   | :-)   | True           | neutron-openvswitch-   |
| 168-2b37bb7ce366     |                    |            |                   |       |                | agent                  |
| 633cb25b-5ff7-4f59   | Metadata agent     | controller |                   | :-)   | True           | neutron-metadata-agent |
| -b97b-c19a554fde42   |                    |            |                   |       |                |                        |
| 778d174b-0200-45bb-a | L3 agent           | controller | nova              | :-)   | True           | neutron-l3-agent       |
| 361-8afc8a3bab67     |                    |            |                   |       |                |                        |
| c40a1bbf-47cc-4a3f-  | DHCP agent         | controller | nova              | :-)   | True           | neutron-dhcp-agent     |
| a2ee-05aa55442bb0    |                    |            |                   |       |                |                        |
| dadec72e-17ec-42ae-  | Open vSwitch agent | controller |                   | :-)   | True           | neutron-openvswitch-   |
| bdcc-d489a43d5135    |                    |            |                   |       |                | agent                  |
+----------------------+--------------------+------------+-------------------+-------+----------------+------------------------+
```

## 3.11. Cài đặt và cấu hình `Horizon`

### Cài đặt và cấu hình các gói
- Cài đặt các gói:
```sh
apt-get install openstack-dashboard
```
- Cấu hình `Horizon` theo các bước sau:
 - Lưu lại cấu hình gốc:
 ```sh
 cp /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.py.orig
 cat /etc/openstack-dashboard/local_settings.py.orig | egrep -v '^#|^$' > /etc/openstack-dashboard/local_settings.py
 ```
 - Chỉnh sửa lại file `/etc/openstack-dashboard/local_settings.py` theo các bước sau:
     - Cấu hình dashboard sử dụng các OpenStack services trên máy `controller`:
     ```sh
     OPENSTACK_HOST = "controller"
     ```
     - Cho phép mọi host truy cập dashboard:
     ```sh
     ALLOWED_HOSTS = ['*', ]
     ```
     - Cấu hình `memcached`:
     ```sh
     CACHES = {
         'default': {
              'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
              'LOCATION': 'controller:11211',
         }
     }
     ```
     - Kích hoạt Identity API version 3:
     ```sh
     OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST
     ```
     - Kích hoạt hỗ trợ cho nhiều domains:
     ```sh
     OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
     ```
     Chú ý: bước này có thể bỏ qua.
     - Cấu hình API version:
     ```sh
     OPENSTACK_API_VERSIONS = {
         "identity": 3,
         "image": 2,
         "volume": 2,
     }
     ```
     - Cấu hình domain mặc định là `default`:
     ```sh
     OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"
     ```
     - Cấu hình `user` là role mặc định cho các user truy cập qua dashboard:
     ```sh
     OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"
     ```
     - Chỉnh sửa lại timezone:
     ```sh
     TIME_ZONE = "Asia/Ho_Chi_Minh"
     ```
     Chú ý kiểm tra timezone trên host cho đúng với cấu hình (thực hiện các lệnh sau trên command line):
     ```sh
     timedatectl
     # Kết quả tương tự như sau
           Local time: Tue 2016-10-25 11:07:21 ICT
       Universal time: Tue 2016-10-25 04:07:21 UTC
             RTC time: Tue 2016-10-25 04:07:21
            Time zone: Asia/Ho_Chi_Minh (ICT, +0700)
      Network time on: yes
     NTP synchronized: yes
      RTC in local TZ: no
     ```
     Nếu timezone không khớp với giá trị `Asia/Ho_Chi_Minh` thì thiết lập lại như sau:
     ```sh
     timedatectl set-timezone Asia/Ho_Chi_Minh
     ```

### Kết thúc quá trình cài đặt
- Khởi động lại web server apache:
```sh
service apache2 reload
```
- Mở trình duyệt, truy cập địa chỉ: `http://controller/horizon`. Đăng nhập với domain là `default`, tài khoản `admin` hoặc `demo`, password là `Welcome123`.

# 4. Cài đặt trên COMPUTE NODE

## 4.1. Thiết lập IP, hostname
- Login với tài khoản thường và chuyển sang tài khoản root
```sh
su -
```

- Thiết lập địa chỉ IP theo đúng phân hoạch. Sửa file `/etc/network/interfaces` với nội dung như sau:
```sh
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

# MANAGEMENT NETWORK
auto ens3
iface ens3 inet static
address 10.20.0.197/24

# EXTERNAL NETWORK
auto ens4
iface ens4 inet static
address 172.16.69.197/24
gateway 172.16.69.1
dns-nameservers 8.8.8.8

# DATA NETWORK
auto ens5
iface ens5 inet static
address 10.10.20.197/24
```

- Khởi động lại toàn bộ các card mạng sau khi thiết lập IP
```sh
ifdown -a && ifup -a
```

- Kiểm tra lại kết nối tới gateway và internet:
```sh
ping 172.16.69.1 -c 4
PING 172.16.69.1 (172.16.69.1) 56(84) bytes of data.
64 bytes from 172.16.69.1: icmp_seq=1 ttl=64 time=0.348 ms
64 bytes from 172.16.69.1: icmp_seq=2 ttl=64 time=0.320 ms
64 bytes from 172.16.69.1: icmp_seq=3 ttl=64 time=0.375 ms
64 bytes from 172.16.69.1: icmp_seq=4 ttl=64 time=0.263 ms

--- 172.16.69.1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 2997ms
rtt min/avg/max/mdev = 0.263/0.326/0.375/0.045 ms
```
```sh
ping google.com -c 4
PING google.com (203.162.236.234) 56(84) bytes of data.
64 bytes from static.vnpt.vn (203.162.236.234): icmp_seq=1 ttl=58 time=0.570 ms
64 bytes from static.vnpt.vn (203.162.236.234): icmp_seq=2 ttl=58 time=0.585 ms
64 bytes from static.vnpt.vn (203.162.236.234): icmp_seq=3 ttl=58 time=0.672 ms
64 bytes from static.vnpt.vn (203.162.236.234): icmp_seq=4 ttl=58 time=0.617 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 2999ms
rtt min/avg/max/mdev = 0.570/0.611/0.672/0.039 ms
```

- Cấu hình hostname. Sửa file `/etc/hostname`, thực hiện lệnh sau:
```sh
echo "compute1" > /etc/hostname
```

- Cập nhật lại file `/etc/hosts` để phân giải từ IP sang hostname và ngược lại với nội dung như sau:
```sh
127.0.0.1   localhost
127.0.1.1   compute1
10.20.0.196 controller
10.20.0.197 compute1
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

- *Chú ý:* Không xóa hai dòng cấu hình với địa chỉ `127.0.0.1`

- Cập nhật các gói cho hệ thống
```sh
apt-get update
```

## 4.2. Cài đặt NTP
- Cài đặt gói chrony (tương đương với gói NTP)
```
apt-get install chrony
```

- Cấu hình chrony. Mở file `/etc/chrony/chrony.conf`. Tìm tới dòng `pool 2.debian.pool.ntp.org offline iburst`, comment lại dòng đó rồi chỉnh sửa lại như sau:
```sh
#pool 2.debian.pool.ntp.org offline iburst
server controller iburst
```

- Khởi động lại dịch vụ NTP
```sh
service chrony restart
```

- Kiểm tra lại hoạt động của NTP: `chronyc sources`
```sh
chronyc sources
210 Number of sources = 1
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^? controller                    0  10     0   10y     +0ns[   +0ns] +/-    0ns
```


## 4.3. OpenStack packages
- Khai báo repos cho OpenStack Newton

```sh
apt-get install software-properties-common
add-apt-repository cloud-archive:newton
```

- Update sau khi khai báo repos cho `OpenStack Newton`
```sh
apt-get update && apt-get dist-upgrade -y
```

- Cài đặt các gói openstack-client
```sh
apt-get install python-openstackclient -y
```

## 4.4. Cài đặt và cấu hình `Nova`
### Cài đặt và cấu hình các gói
- Cài đặt gói:
```sh
apt-get install nova-compute
```

- Cấu hình `nova`:
 - Lưu lại cấu hình gốc:
 ```sh
 cp /etc/nova/nova.conf /etc/nova/nova.conf.orig
 cat /etc/nova/nova.conf.orig | egrep -v '^#|^$' > /etc/nova/nova.conf
 ```
 - Chỉnh sửa lại file `/etc/nova/nova.conf` theo các bước sau:
     - Sửa trong section `[DEFAULT]` các tùy chọn như sau:
     ```sh
     [DEFAULT]
     enabled_apis = osapi_compute,metadata
     transport_url = rabbit://openstack:Welcome123@controller
     auth_strategy = keystone
     my_ip = 10.20.0.197
     use_neutron = True
     firewall_driver = nova.virt.firewall.NoopFirewallDriver
     ```    

     - Sửa trong section `[keystone_authtoken]` các tùy chọn như sau:
     ```sh
     [keystone_authtoken]
     auth_uri = http://controller:5000
     auth_url = http://controller:35357
     memcached_servers = controller:11211
     auth_type = password
     project_domain_name = default
     user_domain_name = default
     project_name = service
     username = nova
     password = Welcome123
     ```
     Chú ý comment lại toàn bộ các dòng cấu hình khác trong sectiion `[keystone_authtoken]` nếu có.

     - Sửa trong section `[vnc]` các tùy chọn như sau:
     ```sh
     [vnc]
     enabled = True
     vncserver_listen = 0.0.0.0
     vncserver_proxyclient_address = $my_ip
     novncproxy_base_url = http://controller:6080/vnc_auto.html
     ```    

     - Sửa hoặc thêm section `[glance]` với nội dung như sau:
     ```sh
     [glance]
     api_servers = http://controller:9292
     ```    

     - Sửa hoặc thêm section `[oslo_concurrency]` với nội dung như sau:
     ```sh
     [oslo_concurrency]
     lock_path = /var/lib/nova/tmp
     ```

     - Thêm section `[neutron]`:
     ```sh
     [neutron]
     url = http://controller:9696
     auth_url = http://controller:35357
     auth_type = password
     project_domain_name = default
     user_domain_name = default
     region_name = RegionOne
     project_name = service
     username = neutron
     password = Welcome123
     ```

     - Xóa bỏ tùy chọn `log-dir` trong section `[DEFAULT]` để tránh gây lỗi.

### Kết thúc tiến trình cài đặt
- Xác định xem compute node cõ hỗ trợ ảo hóa kvm không sử dụng lệnh:
```sh
egrep -c '(vmx|svm)' /proc/cpuinfo
```
Nếu kết quả trả về một con số khác 0 thì có hỗ trợ và không phải làm bước tiếp theo. Nếu kết quả trả về bằng 0 thì thực hiện bước sau.
- Chỉnh sửa lại section `[libvirt]` trong file `/etc/nova/nova-compute.conf` như sau:
```sh
[libvirt]
virt_type = qemu
```
- Khởi động lại dịch vụ:
```sh
service nova-compute restart
```

## 4.5. Cài đặt và cấu hình `Neutron`

### Cài đặt và cấu hình các gói
- Cài đặt gói
```sh
apt-get install neutron-openvswitch-agent
```
- Cấu hình `neutron`
 - Lưu lại cấu hình gốc:
 ```sh
 cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.orig
 cat /etc/neutron/neutron.conf.orig | egrep -v '^#|^$' > /etc/neutron/neutron.conf
 ```
 - Chỉnh sửa lại file `/etc/neutron/neutron.conf` theo các bước sau:
     - Comment lại hoặc xóa toàn bộ các dòng cấu hình trong section `[database]` nếu có.
     - Sửa lại các tùy chọn trong section `[DEFAULT]` như sau:
     ```sh
     [DEFAULT]
     rpc_backend = rabbit
     auth_strategy = keystone
     ```
     - Sửa lại các tùy chọn trong section `[oslo_messaging_rabbit]` như sau:
     ```sh
     [oslo_messaging_rabbit]
     rabbit_host = controller
     rabbit_userid = openstack
     rabbit_password = Welcome123
     ```
     - Sửa lại các tùy chọn trong section `[keystone_authtoken]` như sau:
     ```sh
     [keystone_authtoken]
     auth_uri = http://controller:5000
     auth_url = http://controller:35357
     memcached_servers = controller:11211
     auth_type = password
     project_domain_name = default
     user_domain_name = default
     project_name = service
     username = neutron
     password = Welcome123
     ```
     Chú ý comment lại toàn bộ các dòng cấu hình khác trong section `[keystone_authtoken]` nếu có.

### Cấu hình Open vSwitch agent
- Lưu lại cấu hình gốc:
```sh
cp /etc/neutron/plugins/ml2/openvswitch_agent.ini /etc/neutron/plugins/ml2/openvswitch_agent.ini.orig
cat /etc/neutron/plugins/ml2/openvswitch_agent.ini.orig | egrep -v '^#|^$' > /etc/neutron/plugins/ml2/openvswitch_agent.ini
```
- Chỉnh sửa file `/etc/neutron/plugins/ml2/openvswitch_agent.ini`:
 - Sửa các tùy chọn trong section `[agent]` như sau:
 ```sh
 [agent]
 tunnel_types = vxlan
 l2_population = True
 ```
 - Sửa các tùy chọn trong section `[ovs]` như sau:
 ```sh
 [ovs]
 local_ip = 10.10.20.197
 bridge_mappings =
 ```
 Chú ý tùy chọn `local_ip` thiết lập với IP thuộc dải `DATA NETWORK`

 - Sửa các tùy chọn trong section `[securitygroup]` như sau:
 ```sh
 [securitygroup]
 firewall_driver = iptables_hybrid
 ```

### Kết thúc tiến trình cài đặt
- Khởi động lại các dịch vụ cần thiết
```sh
service nova-compute restart
service neutron-openvswitch-agent restart
```
Tới đây có thể bắt đầu tạo máy ảo.

# 5. Kiểm tra cài đặt
## 5.1. Tạo provider network và tenant network:
Thực hiện các lệnh sau trên máy controller
```sh
source admin-openrc
neutron net-create ext-net --router:external --provider:physical_network provider --provider:network_type flat
neutron subnet-create ext-net 172.16.69.0/24 --name ext-subnet --allocation-pool start=172.16.69.140,end=172.16.69.149 --disable-dhcp --gateway 172.16.69.1
neutron net-create demo-net
neutron subnet-create demo-net 192.168.1.0/24 --name demo-subnet --gateway 192.168.1.1 --dns-nameserver 8.8.8.8
neutron router-create demo-router
neutron router-interface-add demo-router demo-subnet
neutron router-gateway-set demo-router ext-net
```

## 5.2. Tạo instance
Truy cập vào trình duyệt theo địa chỉ: `http://controller/horizon` hoặc `http://<controller_ip>/horizon` và tiến hành tạo instance như sau:
- Tạo flavor (mặc định hệ thống không tạo sẵn flavor), vào tab `Admin -> SYSTEM -> Flavors` tiến hành tạo flavor mới theo các bước sau:
<br><br>
<img src="http://i.imgur.com/XBdq70b.png">
<br><br>
<img src="http://i.imgur.com/Ock364W.png">
<br><br>
<img src="http://i.imgur.com/Ux7vFED.png">
<br><br>
- Tạo instance, vào tab `Project -> COMPUTE -> Instances` tiến hành tạo instance mới theo các bước sau:
<br><br>
<img src="http://i.imgur.com/PkhUds1.png">
<br><br>
<img src="http://i.imgur.com/viGYQJg.png">
<br><br>
<img src="http://i.imgur.com/uwrTsBh.png">
<br><br>
<img src="http://i.imgur.com/wJpE8om.png">
<br><br>
<img src="http://i.imgur.com/kfaQSQc.png">
<br><br>
<img src="http://i.imgur.com/UoFuY2a.png">
<br><br>
Cấp Floating IP cho instance
<br><br>
<img src="http://i.imgur.com/lwHGunT.png">
<br><br>
<img src="http://i.imgur.com/gStmSsQ.png">
<br><br>
<img src="http://i.imgur.com/sTowGPs.png">
<br><br>
<img src="http://i.imgur.com/39SSSjg.png">
<br><br>
<img src="http://i.imgur.com/4Iwp7Hj.png">
<br><br>
Ping từ instance ra internet
<br><br>
<img src="http://i.imgur.com/U6CHcRr.png">
