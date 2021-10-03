#!/bin/bash
count=`ls /dev/* | grep "nvme[0-9]n" | wc -l`
disks=`ls /dev/* | grep "nvme[0-9]n" | xargs echo`
sudo chown gokool:gokool /mnt && \
sudo echo "gokool ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
mkdir -p /mnt/gomap/ && \
sudo mount /mnt/gomap/ && \
sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=$count $disks && \
sudo mkfs.ext4 /dev/md0  && \
mkdir -p /media/nvme && \
sudo mount /dev/md0 /media/nvme && \
sudo chown -R gokool /media/nvme

 && \
sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/nvme0n1 /dev/nvme1n1 && \
sudo mkfs.ext4 /dev/md0  && \
mkdir -p /media/nvme && \
sudo mount /dev/md0 /media/nvme && \
sudo chown -R gokool /media/nvme