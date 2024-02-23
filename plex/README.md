# Plex

## Be Warned

I no longer use plex as jellyfin was better.
But, I could switch back to plex if needed, however my arm64 image on dockerhub is broken and if used will need to be
patched live...or I could patch and push a newer version...but like I said, not using it.

## Install

Basically I did [this](https://www.plex.tv/blog/plex-pro-week-23-a-z-on-k8s-for-plex-media-server/)

1. Add repo:

```bash
helm repo add plex https://raw.githubusercontent.com/plexinc/pms-docker/gh-pages
```

2. Download values file

```bash
wget https://github.com/plexinc/pms-docker/blob/master/charts/plex-media-server/values.yaml
```

3. Modify values file...annoying:

```bash
vim values.yaml
```

Deploy demo using helm and the preset values:

```bash
helm install demo plex/plex-media-server -f values.yaml
```

## Distributed
https://www.reddit.com/r/PleX/comments/mv4bl4/trying_to_deploy_plex_on_kubernetes_but_running/

https://github.com/ressu/kube-plex

## Image

The docker image provided in the helm is only for `x86_64`.
So you have to build your own. Could be possible from native arm system, but that is probably slow.
So you can do it with the command `docker buildx`...

https://github.com/plexinc/pms-docker/blob/master/Dockerfile.arm64

Also had to make some tweaks since it does not seem to autodetect and install the binaries, you need to feed it a custom download URL.
So I went to the plex download page and then set the variable in the dockerfile:

Something like this:
```
export URL=https://downloads.plex.tv/plex-media-server-new/1.32.8.7639-fb6452ebf/debian/plexmediaserver_1.32.8.7639-fb6452ebf_arm64.deb
```

Clear dos newlines:

```
apt install dos2unix
dos2unix /var/run/s6/services/plex/run
```

For testing I had to restart the services via s6:

```
s6-svc -r /var/run/s6/services/plex
```

## It works

http://localhost:32400/web

Google auth is hanging..
Stupid incognitio, use reguler browsering options.
