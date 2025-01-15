# Certs

Letsencrypt is used to obtain an legit signed certificate.
A cron job is run on `rpi1` to update the cert if/when needed.

## Update Certs

First, copy certs from `rpi1` under `/etc/letsencrypt/live/bum.chickenkiller.com`.

Delete previous (expired) cert secret:

```bash
kubectl delete secret bum.chickenkiller.com
```

Add cert as new secret:

```bash
kubectl create secret tls bum.chickenkiller.com --key privkey.pem --cert fullchain.pem
```

If this is the first time applying the cert, then add into service spec:

```yaml
spec:
  tls:
    - hosts:
        - ingress-demo.example.com
      secretName: ingress-demo-tls
```

This should already have been done if you are just renewing a previous cert.
