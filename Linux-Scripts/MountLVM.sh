PhysVol = "$1"
VolSize = "$2"
MountDir = "$3"

sudo pvcreate $PhysVol
sudo pvdisplay $PhysVol

sudo vgcreate volgrp1 $PhysVol

sudo lvcreate -L $VolSize -n LogVol1
sudo lvdisplay /dev/VolGrp1/LogVol1
sudo mount /dev/VolGrp1/LogVol1 $MountDir
