# Install Notes
Basic idea comes from [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way).
However, here are some things of note...

1. Used docker for inital build of kubernetes binaries so that I can have `armv6`, `armv7`, and `aarm64` all on the same version.
2. API version of apiserver specified by other configs matter. I had to use the latest which no longer uses suffix like `alpha` or `beta`, it is just plain o'l `v1`.
3. Also due to various version changes, some flags in the `containerd` and `kublete` flags were obsolete,
   most I could remove from `systemc` unit file, but 1 I had to move to the cooresponding config.
5. The `armv7l` compiled `kubelet` does not run on `aarm64` arch, even though the other `armv7l` binaries may.
   So I needed to compile kubernetes as `aarm64` in order to get `kubelete` working on `rpi[3-4]`.
6. Needed to install `netfilter-persistent`, perhaps I missed this step, or maybe things changed since the writting of `KTHW`.
7. I ended up using the `admin.kubeconfig` which contains the authentication of the `admin` user, rather than the individual kubeconfig that should have been used for the `kube-proxy`.
8. Had to download a newer version of `containerd` (`1.6.X`), the native Debian version (`~1.3`) had some kind of bug.
   This was easy enough to do with `aarm64` (officially supported), but for `armv7` I had to look around [here](https://github.com/alexellis/containerd-arm/releases).
9. Used newer method of installing coredns via helm charts ([helm binaries](https://github.com/helm/helm/releases), [install instructions](https://github.com/coredns/helm)
10. Had to move cni plugins to `/opt/cni/bin`, they were in `/opt/cni` for some reason.
11. Had to resume nodes after backup, with `kubectl uncordon rpi4`.
12. Found compatible [runc](https://github.com/opencontainers/runc/releases) with from [containerd repo](https://github.com/containerd/containerd/blob/v1.6.24/script/setup/runc-version).
13. Symlinked `runc` to `/usr/local/bin` but still kept the deb package installed too. Should probably remove it at some point...but it wants to remove `containerd` which I also installed on top of the deb package, it was easier (and dirty).
14. Had to add some flags to RPi kernels (notice the 4 cgroup options, the last one is for v1 not v2):
```bash
 cat /boot/cmdline.txt
console=serial0,115200 console=tty1 root=PARTUUID=79aa9fb7-02 rootfstype=ext4 cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 fsck.repair=yes systemd.unified_cgroup_hierarchy=0 rootwait
```
15. Use the cgroup service since manually doing this may not be working correctly (OOMs):
```bash
sudo apt-get install libcgroup1 cgroup-tools cgroupfs-mount

# Always dead, I guess this is masked by another service...
systemctl status cgroupfs-mount.service

# Can check by looking at mounts, should be something like; /sys/fs/cgroup/memory and /sys/fs/cgroup/cpu
mount | grep cgroup
```

>NOTE: After #14 and #15 are updated, then reboot.

16. Helm install of coredns was working, but the `Corefile` was default. To update/edit had to use this:
```bash
kubectl -n kube-system edit configmap coredns-coredns
```
This still failed, since some fields cannot be changed (ie. `clusterIP`), so had to reinstall via `helm` like so:
```bash
# Had an error, but container, deploy, and services were all gone
helm uninstall coredns
# Re-install with correct clusterIP (also references in kublete config...)
helm --namespace=kube-system install --set serviceAccount.create=true --set service.clusterIP=10.32.0.10 coredns coredns/coredns
#helm --namespace=kube-system install --set serviceAccount.name=coredns --set serviceAccount.create=true --set service.clusterIP=10.32.0.10 coredns coredns/coredns
```
17. Also useful there were some deployment yamls I wanted to check, so I used this:
```bash
kubectl get deploy -n kube-system -o yaml
```
I am pretty sure you can use this for singular deployment units by specifing the name, as well as nodes if you change the type from `deploy`.

18. Still had `coredns` routing issues to and from the same node that runs the service and container. Probabaly due to the lack of `sysctl -w net.bridge.bridge-nf-call-iptables=1`, thus it was suggested to use `flannel` instead of `netfilter` on RPis 🙃. On second thought, `flannel` requires the same kernel flag, so what is the point in changing to `flannel` 🙃🙃. Also found that other users have used `netfilter` on RPi for Kubernetes, so that seems legit:
```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
 
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

# Interesting things for later

* [Netowrk Mesh layer](https://istio.io/latest/) - Jake used `srv/istio` name space for creating a port forward via kubectl.
Perhaps a more advanced method than I need, but good to know it exists. Has some the ability to control flow in and out of a cluster (Ingress/Egress).
* [Scalable storage for Prometheus](https://cortexmetrics.io/) - Could be useful for monitoring large clusters, or many clusters.

# Do NOT install using helm

```bash
helm install flannel --set podCidr="10.32.0.0/24" --namespace kube-flannel flannel/flannel
```
Better to use `kubectl apply flannel.yml`, which contains RBAC.

# Did I need this?

I needed apparmor:

```bash
sudo apt install apparmor
```

# Tunned Pis to use only 16MB of gpu memory from /boot/config.txt

Why did I do this? Not sure, just to max system memory?

```
gpu_mem=16
```

# Work out IP ranges very carefully

The service ip range for normal Kubernets defaults to 10.96.0.0/12 and the pod ip range differs from on the CNI you use, but it's often common to set it to 10.244.0.0/16
Since this is a custom roll out, then the IPs are not the same as the normal Kubernetes defaults (even Rancher and Goolge have there own ranges).

Check once, and it was a mess, IP ranges:
  * internal FW   - 10.240.0.0/24,10.200.0.0/16
  * k controllers - 10.240.0.1${i} (254 nodes)
  * cluster CIDR  - 10.200.0.0/16 (254 subnets)
  * worker node   - 10.240.0.2${i}
    * meta - pod-cidr=10.200.${i}.0/24
  * k api         - service-cluster-ip-range=10.32.0.0/24
  * k controller  - service-cluster-ip-range=10.32.0.0/24
    * cluster-cidr=10.200.0.0/16

clusterIP (service)?
first IP address (10.32.0.1) from the address range (10.32.0.0/24)

Part of why this was confusing is that the "the hard way" instructrions mask some of the complexity by using in built Google variables, and then later calls those variables
when configuring Kubernetes.
I believe these variables were sometimes dynamically created based on the number of controllers one was deploying, thus each controller used a different value and was NOT
a common variable amoung all the controllers.

# Fixing IP Ranges

Added to kube-manager systemd unit file.
This allows auto assignment of cidrs, sometimes not super clean, but better that then hardcoding each unique range:

```
 --allocate-node-cidrs=true \
```

Looks like the IP ranges are in sequence by default?
When using the auto assing mentioned above, the ranges are sequencially assigned:

```bash
kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}'
kubectl describe node | egrep 'PodCIDR|Name:'
```

So I fixed the kubelet and cni files to match what kubernetes had mapped in the above commands.

# Manually load vxlan module

I had to manually do this the first time when configuring and testing without reboot:

```bash
sudo modprobe vxlan
```

But I think this is not needed if/when reboot occurs.

