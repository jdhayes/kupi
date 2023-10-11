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
