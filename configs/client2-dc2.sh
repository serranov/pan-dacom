ip link add link eth1 name eth1.20 type vlan id 20
ip addr add 192.168.0.22/24 dev eth1.20
ip link set eth1.20 up
ip route add 192.168.0.0/24 via 192.168.0.254 dev eth1.20
