# Certs

Add as secret:
```bash
kubectl create secret tls bum.chickenkiller.com --key privkey.pem --cert fullchain.pem
```

Then add into service spec:

```yaml
spec:
  tls:
    - hosts:
        - ingress-demo.example.com
      secretName: ingress-demo-tls
```
