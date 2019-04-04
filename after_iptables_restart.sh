

#echo 163840 > /sys/module/nf_conntrack/parameters/hashsize
echo 327680 > /sys/module/nf_conntrack/parameters/hashsize
sysctl -p

