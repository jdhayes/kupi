# Storage

There are tons of storage options, I went with the manual for now since it was easy and I don't care.

## Manual

Manual storage described [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/).

I created a beast and mini beast PV (PersistentVolume) and PVC (PersistentVolumeClaim).
Each of these are just a single USB disk on rpi4 and rpi5 respectively.

The drives are very different in size, 8TB and 0.5 TB, so I haven't yet decided on the best way to have shared robust storage on all the nodes.

## MinIO

MinIO could be good.

## Longhorn

Longhorn was interesting, and seems easy and "lightwieght".
I already have this running on a different K3s cluster.
Some stories of corruption though...
