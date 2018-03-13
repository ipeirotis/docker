#!/bin/bash

# check if external disk is formatted
sudo /sbin/blkid -s TYPE -o value /dev/sdb

if [[ $? -ne 0 ]]; then
    sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
fi

sudo mkdir -p /mnt/disks/notebook_dir
sudo mount -o discard,defaults /dev/sdb /mnt/disks/notebook_dir
sudo chmod a+w /mnt/disks/notebook_dir
