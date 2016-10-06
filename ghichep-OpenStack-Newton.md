# Các ghi chép về OpenStack Newton


- Khai báo gói cài đặt OpenStack Newton trên Ubuntu 16.04
```sh
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu xenial-updates/newton main" | sudo tee /etc/apt/sources.list.d/newton-uca.list
sudo apt-get install -y ubuntu-cloud-keyring
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && init 6

- Tham khảo: http://www.gossamer-threads.com/lists/openstack/dev/55415
```