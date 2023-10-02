# kupi
![image](images/kupi.png)

# Table of Contents
* [Basic Outline](#basic-outline)
* [OS Install](#os-install)
* [Roles](#roles)
* [Dependencies](#dependencies)
* [Kubernetes](#kubernets)

# Objective
Kubernetes on Pis (and Panda?)

# Basic Outline
Things will likely change as the projects morphs and adapts.

## OS Install

Install Debian 11 (Stock kernel ~5.12) via [Debian on Panda](https://forum.digikey.com/t/debian-getting-started-with-the-pandaboard/12839)
* PandaBoard

Install PiOS (Custom kernel >6.0, with Debian 11 system root):

* rpi1
* rpi3
* rpi4

> Note: Panda vs Pi, not exactly the same, but close enough?

## Roles
### LB:
Maybe make `rpi1` a "login"/"head" node, possibly also a load balancer ([Quick LB](https://www.pluralsight.com/cloud-guru/labs/aws/setting-up-a-frontend-load-balancer-for-the-kubernetes-api
)):

* 10/100 MBs - slow :(
* 512MB RAM - low :(
* 1 Core/Thread - small :(

### Workers
Similar specs for panda vs rpi3:

* 10/100 MBs - slow :(
* 1 GB RAM
* 2,4 Cores (panda,rpi3 respectively)

### Controllers
Definitely a controller: rpi4, since these are heavier than I thought (needs to run various services; etcd, api-server, and more):

* 10/100/1000 MB - :)
* 4 GB RAM
* 4 Cores

## Dependencies
Needed to compile kubernetes binaries for `armv6l`, but if `rpi1` is going to be just a simple LB, then maybe we dont even need to do this.
Since I already have to code to build, I may just keep as is for now, but we could change this and use the official binaries.

One positive side-affect is that if we wanted to run `kubectl` from the LB, we could, thus allowing `rpi` to be used as a "login"/"head" node.

## Kubernets
Configure/Install Kubernetes via [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way/).
Lots of copy paste, but honestly, not that hard.

