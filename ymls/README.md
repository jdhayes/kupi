# Additional YMLS to get stuff working

# DNS

coredns was installed via helm.

# Flannel

kubectl apply -f flannel.yml

# Add Node

There are various ymls that I tried to get this done, but it seems as long as the normal flow of kub-the-hard-way is followed it seems to work.

Dont really nead this, and plus, I couldn't get it to work with this custom setup anyway:
https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/
