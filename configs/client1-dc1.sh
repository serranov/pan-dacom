ip link add link eth1 name eth1.10 type vlan id 10
ip addr add 192.168.0.11/24 dev eth1.10
ip link set eth1.10 up
ip route add 192.168.0.0/24 via 192.168.0.254 dev eth1.10
