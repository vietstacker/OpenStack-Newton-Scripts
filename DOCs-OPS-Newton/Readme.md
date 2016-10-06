# Ghi chép hướng dẫn cài đặt OpenStack Newton - lược dịch theo docs

# 1. Lịch sử tài liệu

# 2. Chuẩn bị
## 2.1. Mô hình

## 2.2. Yêu cầu
- Về cấu hình từng máy chủ

- Về IP

## 2.3 Chú ý khi chuẩn bị

# 3. Cài đặt trên CONTROLLER NODE

## 3.1. Thiết lập IP, hostname
- Login với tài khoản thường và chuyên sang tài khoản root
```sh
su -
```

- Thiết lập địa chỉ IP theo đúng phân hoạch
```sh

```

## 3.2. Cài đặt NTP
- Cài đặt gói chrony (tương đương với gói NTP)
```
apt-get install chrony
```

- Cấu hình chrony

## 3.3. OpenStack packages
- Khai báo repos cho OpenStack Newton

```sh
apt-get install software-properties-common
add-apt-repository cloud-archive:newton
```

- Update sau khi khai báo repos cho `OpenStack Newton`
```sh
apt-get update && apt-get dist-upgrade
```

- Cài đặt các gói openstack-client 
```sh
apt-get install python-openstackclient
```

## SQL database 
### Cài đặt và cấu hình MariaDB
- Cài đặt MariaDB
```sh
apt-get install mariadb-server python-pymysql
```

- Cấu hình MariaDB


## Cài đặt và cấu hình `Keystone`
### Chuẩn bị cho cài đặt `Keystone`
- Tạo Database
```sh
mysql -u root -pWelcome123

CREATE DATABASE keystone;

GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'Welcome123';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'Welcome123';
```

### Cài đặt và cấu hình các thành phần của `Keystone`
- Disable chế độ start dịch vụ keystone tự động sau khi cài
```sh
echo "manual" > /etc/init/keystone.override
```

- Cài đặt các gói của `keystone` trên node CONTROLLER
```sh
apt-get install keystone apache2 libapache2-mod-wsgi
```

- Sửa file cấu hình của `keystone`
 - Tạo file backup cho file cấu hình gốc của `keystone` để khôi phục khi cần thiết.
 ```sh
 cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.orig
 cat /etc/keystone/keystone.conf.orig | egrep -v '^#|^$' > /etc/keystone/keystone.conf 
 ```
 Trong tab `[DEFAULT]` sửa như dưới đây.
 
```sh
[DEFAULT]
admin_token = Welcome123

[database]
connection = mysql+pymysql://keystone:Welcome123@10.10.10.140/keystone


[token]
provider = fernet

# Cài đặt trên COMPUTE NODE



