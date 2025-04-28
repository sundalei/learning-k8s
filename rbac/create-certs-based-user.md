# Creating User 'sky' in Kubernetes Kind Cluster

## Prerequisites

- A running kind cluster
- kubectl installed
- openssl installed

## Steps

### 1. Generate Private Key

Create a private key for the user 'sky':

```bash
openssl genrsa -out sky.key 2048
```

### 2. Create Certificate Signing Request (CSR)

Generate a CSR for the user:

```bash
openssl req -new -key sky.key -out sky.csr -subj "/CN=sky/O=shield"
```

### 3. Create and Approve Kubernetes CSR

Create and approve the CSR in one step:

```bash
# Create CSR
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: sky-csr
spec:
  request: $(cat sky.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages:
  - client auth
EOF

# Approve CSR
kubectl certificate approve sky-csr
```

### 4. Get the Certificate

Extract the approved certificate:

```bash
kubectl get csr sky-csr -o jsonpath='{.status.certificate}' | base64 -d > sky.crt
```

### 5. Configure Kubernetes Context

Set up the credentials and context for the user:

```bash
# Create credentials
kubectl config set-credentials sky --client-key=sky.key --client-certificate=sky.crt --embed-certs=true

# Create context
kubectl config set-context sky@kind-kind --cluster=kind-kind --user=sky
```

### 6. Using the New Context

Switch to the new context or use it with the --context flag:

```bash
# Switch context
kubectl config use-context sky@kind-kind

# Or use with --context flag
kubectl --context=sky@kind-kind get pods -n shield
```

## Verification

Test the user access:

```bash
kubectl --context=sky@kind-kind auth can-i get deployments -n shield
```

## Note

- Keep the private key (sky.key) secure
- The certificate (sky.crt) is valid for 24 hours (86400 seconds)
- The user belongs to the 'shield' organization
