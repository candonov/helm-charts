# helm-charts
### Set account number
```
export ACCOUNT_NUMBER=$(aws sts get-caller-identity --output json | jq -r ".Account" | tr -d '[:space:]')
```
### Build, push, and install helm chart
Log in to ecr and create helm repo
```
aws ecr get-login-password --region us-east-1 | helm registry login \
       --username AWS --password-stdin $ACCOUNT_NUMBER.dkr.ecr.us-east-1.amazonaws.com
aws ecr create-repository --repository-name helm-demo-app-chart --region us-east-1
```
Build and push chart
```
helm package demo-app
helm push helm-demo-app-chart-0.1.0.tgz oci://$ACCOUNT_NUMBER.dkr.ecr.us-east-1.amazonaws.com/
```
Install chart
```
helm install demo-app oci://$ACCOUNT_NUMBER.dkr.ecr.us-east-1.amazonaws.com/helm-demo-app-chart --version 0.1.0 -f values-dev.yaml
```
## Set up ArgoCD to pull the helm-chart
Create IRSA
```
eksctl create iamserviceaccount \
    --name argocd-ecr-updater \
    --namespace argocd \
    --cluster <cluster-name> \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
    --approve \
    --override-existing-serviceaccounts
```
Create empty secret
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  labels:
    argocd-ecr-updater: enabled
    argocd.argoproj.io/secret-type: repository
  name: helm-ecr
stringData:
  enableOCI: "true"
  name: helm-ecr
  type: helm
  url: $ACCOUNT_NUMBER.dkr.ecr.us-east-1.amazonaws.com
  username: AWS
  password: ""
EOF
```
Install argocd-ecr-updater helm chart to autorotate the password
```
helm repo add argocd-ecr-updater https://karlderkaefer.github.io/argocd-ecr-updater
helm upgrade --install argocd-ecr-updater -n argocd --set serviceAccount.create=false --set serviceAccount.name=argocd-ecr-updater argocd-ecr-updater/argocd-ecr-updater
```

