# Virt

# Setting up hypervisor (home lab)

This is a sub optimal multi tenancy configuration, and is mostly notes for my home network while I get broader networking implemented.

1. Install libvirt
2. Create a bridge for the default interface as br0
3. Add iptables routes

Where $SUBNET is the subnet to add and $HOST_IP is where Virt is being served, or a proxy to the server

```
# add the subnet to the host, where $SUBNET is the subnet, specifying the gateway for the IP
ip a add $SUBNET dev br0

# route all outbound connections
iptables -t nat -I POSTROUTING -o br0 --src $SUBNET -j MASQUERADE

iptables -t nat -I POSTROUTING -o br0 --dest $subnet -

# redirect to the metadata endpoint
iptables -t nat -I PREROUTING -p tcp --dport 80 -d 169.254.169.254 -j DNAT --to-destination $HOST_IP
```

4. Additionally the router for the server needs the following route

```
10.1.0.0/24 via 10.0.0.2 dev eth1.2  proto zebra
```

5. Add the subnet to Virt

6. VMs can reach 169.254.169.254/ci and the general server at this point, and the VM can be logged into on the network by its IP.
