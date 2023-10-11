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
14. Had to add some flags to RPi kernels (notice the 3 cgroup options):
```bash
 cat /boot/cmdline.txt
console=serial0,115200 console=tty1 root=PARTUUID=79aa9fb7-02 rootfstype=ext4 cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 fsck.repair=yes rootwait
```
15. May have to manually mount cgroups, or configure systemd service to do it (existing serivce?):
```bash
sudo mkdir /sys/fs/cgroup/systemd
sudo mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
```
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
```
17. Also useful there were some deployment yamls I wanted to check, so I used this:
```bash
kubectl get deploy -n kube-system -o yaml
```
I am pretty sure you can use this for singular deployment units by specifing the name, as well as nodes if you change the type from `deploy`.

18. Still had `coredns` routing issues to and from the same node that runs the service and container. Probabaly due to the lack of `sysctl -w net.bridge.bridge-nf-call-iptables=1`, thus it was suggested to use `flannel` instead of `netfilter` on RPis 🙃.
