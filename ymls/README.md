# Additional YMLS to get stuff working

# DNS

coredns was installed via helm.

# Flannel

kubectl apply -f flannel.yml

# Add Node

There are various ymls that I tried to get this done, but it seems as long as the normal flow of kub-the-hard-way is followed it seems to work.

Dont really nead this, and plus, I couldn't get it to work with this custom setup anyway:
https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/

# Update Roles

Not sure why the role is twice like that, but it does seem to work:

```bash
kubectl label node rpi3 rpi4 rpi5 node-role.kubernetes.io/master=master
kubectl label node rpi3 rpi4 rpi5 node-role.kubernetes.io/etcd=etcd
kubectl label node rpi3 rpi4 rpi5 node-role.kubernetes.io/control-plane=control-plane
```

This labels probably mean something in K3s and could be used to get a list of node dynamically.
But I just set them manually to keep things organized.
