# Upgrade

Seems like 3.5 is compatible with 3.4, but probably best to have them all on the same version:
https://etcd.io/docs/v3.3/upgrades/upgrade_3_5/

# Adding a Node

## Certs

I think I need to generetate all new certs for etcd client and server, which means restarting kubernetes.

## Member Management

https://etcd.io/docs/v3.6/tutorials/how-to-deal-with-membership/

## Add Node

```bash
sudo etcdctl --endpoints=https://192.168.1.14:2379 --cert-file=/etc/etcd/kubernetes.pem --key-file=/etc/etcd/kubernetes-key.pem --ca-file=/etc/etcd/ca.pem member add rpi5 https://192.168.1.15:2380
```

After that I updated the etcd systemd unit file (flag `--initial-cluster=node1,node2,etc...`) to match the newly added node and set `--initial-cluster-state existing` so that it wouldnt try to create a new one.

Lastly, once the service looked healthy, I set the `--initial-cluster-state new` since that is what is should be after a node has already joined.
I think this is becuase each node will create a "new" cluster open startup and they will all vote based on clusterid and a leader is selected.
I assume the "existing" value would only be needed for the first time a node joins, as it cannot create its own cluster yet.

## Remove node

To remove a node, need to get ID first like this:

```
sudo etcdctl --endpoints=https://192.168.1.14:2379 --cert-file=/etc/etcd/kubernetes.pem --key-file=/etc/etcd/kubernetes-key.pem --ca-file=/etc/etcd/ca.pem member list
```

The localhost IP works too?

```
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem
```

# Security?

https://etcd.io/docs/v3.5/op-guide/security/

# Recovery

Basic idea comes from [here](https://github.com/etcd-io/etcd/blob/v3.2.32/Documentation/op-guide/recovery.md).

## Save

Easy enough to copy the `/var/lib/etcd/member/snap/db` file, but there is also a `save` snapshot command that would be better suited for when the system is running.

```bash
ETCDCTL_API=3 etcdctl --endpoints $ENDPOINT snapshot save snapshot.db
```

## Restore

After you a db file  you can restore on any machine like this:

```
# Remove previous data
rm -rf /var/lib/etcd/

# Load data from snap
ETCDCTL_API=3 etcdctl --endpoints=https://192.168.1.14:2379 --cert=/etc/etcd/kubernetes.pem --key=/etc/etcd/kubernetes-key.pem --cacert=/etc/etcd/ca.pem --name rpi4 --initial-cluster rpi4=https://192.168.1.14:2380 --initial-advertise-peer-urls=https://192.168.1.14:2380 --skip-hash-check=true --data-dir=/var/lib/etcd --initial-cluster-token=etcd-cluster-0 snapshot restore snapshot.db

# Run etcd in single node cluster
etcd --name rpi4 --listen-client-urls https://192.168.1.14:2379 --advertise-client-urls https://192.168.1.14:2379 --listen-peer-urls https://192.168.1.14:2380 --cert-file=/etc/etcd/kubernetes.pem  --key-file=/etc/etcd/kubernetes-key.pem  --peer-cert-file=/etc/etcd/kubernetes.pem  --peer-key-file=/etc/etcd/kubernetes-key.pem  --trusted-ca-file=/etc/etcd/ca.pem  --peer-trusted-ca-file=/etc/etcd/ca.pem --peer-client-cert-auth --client-cert-auth --initial-cluster rpi4=https://192.168.1.14:2380 --data-dir /var/lib/etcd
```

You might be able to use the same etcd unit file, but will need to modify the `--initial-cluster` flag to only have the one node.
After that, just add the other nodes members as before.
