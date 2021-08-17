dd if=/dev/zero of=$1 bs=512 count=2880
DISK_NAME=$(hdiutil attach -nomount $1)
newfs_msdos $DISK_NAME
hdiutil detach $DISK_NAME
