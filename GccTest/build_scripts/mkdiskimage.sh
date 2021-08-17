dd if=/dev/zero of=$1 bs=512 count=2880
mkfs.fat -F 12 -n "NBOS" $1
