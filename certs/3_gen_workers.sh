#!/bin/bash

#NODES='panda rpi{3,4}'
NODES='rpi{3..5}'

for instance in $NODES; do
cat > ${instance}-csr.json <<EOF 
{
  "CN": "system:node:${instance}", "key": { "algo": "rsa", "size": 
    2048
  },
  "names": [ { "C": "US", "L": "Corona", "O": "system:nodes", "OU": 
      "Kubernetes The Hard Way", "ST": "California"
    }
  ]
}
EOF

  #EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
  #  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')
  EXTERNAL_IP='rpi1,192.168.1.11'

  #INTERNAL_IP=$(gcloud compute instances describe ${instance} \
  #  --format 'value(networkInterfaces[0].networkIP)')
  INTERNAL_IP=$(grep $instance /etc/hosts | awk '{print $1}')

  cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -hostname=${instance},${INTERNAL_IP},${EXTERNAL_IP} \
    -profile=kubernetes \
    ${instance}-csr.json | cfssljson -bare ${instance}
done
