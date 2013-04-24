mkdir /tmp/image
sudo mount -o loop /mnt/sda1/tce/optional/virtualbox-ose-additions.tcz /tmp/image
sudo cp /tmp/image/usr/local/sbin/mount.vboxsf /usr/local/sbin
sudo modprobe vboxsf >> /home/tc/out.txt
mkdir /mnt/Downloads >> /home/tc/out.txt
sudo mount -t vboxsf -o nodev Downloads /mnt/Downloads >> /home/tc/out.txt
while [ 1 -eq 1 ]
do
sudo abiword -g 1000 1000
done

