FROM ubuntu:20.04

# Set work directory
WORKDIR /root/

# Prep private key
RUN mkdir -p /root/.ssh
COPY id_rsa /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh
RUN chmod 700 /root/.ssh/id_rsa

# Install pkgs
RUN DEBIAN_FRONTEND=noninteractive apt update
#RUN DEBIAN_FRONTEND=noninteractive apt install -y wget git gcc-arm-linux-gnueabihf make
RUN DEBIAN_FRONTEND=noninteractive apt install -y wget git gcc-arm-linux-gnueabi make

# Get source code
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN git clone git@github.com:kubernetes/kubernetes.git

# Build binaries for Pi1
RUN cd kubernetes && \
    sed -i '/export GOARCH=/a export GOARM=5' hack/lib/golang.sh && \
    sed -i 's/-arm-linux-gnueabihf-gcc/-arm-linux-gnueabi-gcc/' hack/lib/golang.sh && \
    make all WHAT=cmd/kube-proxy KUBE_BUILD_PLATFORMS=linux/arm && \
    make all WHAT=cmd/kubelet KUBE_BUILD_PLATFORMS=linux/arm && \
    make all WHAT=cmd/kubectl KUBE_BUILD_PLATFORMS=linux/arm

# Copy binary to PI
RUN ssh-keyscan $PI >> /root/.ssh/known_hosts
RUN scp -i /root/.ssh/id_rsa -r kubernetes/_output/local/go/bin/linux_arm $USER@$PI:~/
