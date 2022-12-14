echo "$(hostname) $(date) Mounting attached disk"
sudo lsblk
part=$(sudo lsblk | grep 'part /' | grep -oh 'sd[a-z]1' | cut -c1-3 | uniq)
echo "part=$part"
devs=$(sudo lsblk | grep disk | grep -v $part | grep -oh 'sd[a-z]')
echo "devs=$devs"

for dev in $devs; do
  # if we ever need to resize/grow the partition the command below should do it
  # e2fsck -f -y /dev/sdb
  # resize2fs /dev/sdb
  sudo mkdir -p /mnt/disks/$dev
  # make sure the `mount` command fails gracefully using the `||`
  # or the startup-script may be aborted entirely
  RESULT=0
  sudo mount -o discard,defaults /dev/$dev /mnt/disks/$dev || RESULT=1
  if [ $RESULT -eq 0 ]; then
    echo "Mounted /dev/$dev to /mnt/disks/$dev"
  else
    echo "Formatting /dev/$dev to ext4"
    sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$dev
    sudo mount -o discard,defaults /dev/$dev /mnt/disks/$dev
  fi
done
df -h
