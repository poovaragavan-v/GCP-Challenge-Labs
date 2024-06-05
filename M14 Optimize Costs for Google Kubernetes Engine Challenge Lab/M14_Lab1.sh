Task Basic Information

PROJECT_ID=qwiklabs-gcp-01-ac1b4e1efc06
ClusterName=onlineboutique-cluster-156
PoolName - optimized-pool-4134
MAx Replcias - 11
zone=europe-west4-c

# Task 1

ZONE=europe-west4-c

gcloud container clusters create onlineboutique-cluster-156 --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-standard-2 --num-nodes=2

# Create the dev namespace
kubectl create namespace dev

# Create the prod namespace
kubectl create namespace prod

# List clusters to verify the newly created cluster
gcloud container clusters list --project=qwiklabs-gcp-01-ac1b4e1efc06

# List namespaces in the cluster
kubectl get namespaces


# Task 2

gcloud container node-pools create optimized-pool-4134 \
    --cluster=onlineboutique-cluster-156 \
    --machine-type=custom-2-3584 \
    --num-nodes=2 \
    --zone=europe-west4-c \
    --project=qwiklabs-gcp-01-ac1b4e1efc06

# Cordon off the default pool nodes
kubectl cordon $(kubectl get nodes -o=jsonpath='{.items[?(@.metadata.labels.cloud\.google\.com/gke-nodepool=="default-pool")].metadata.name}')

# Drain the default pool nodes
kubectl drain --ignore-daemonsets --delete-local-data $(kubectl get nodes -o=jsonpath='{.items[?(@.metadata.labels.cloud\.google\.com/gke-nodepool=="default-pool")].metadata.name}')

# Verify Migration
kubectl get pods -o wide

gcloud container node-pools delete default-pool \
    --cluster=onlineboutique-cluster-156 \
    --zone=europe-west4-c \
    --project=qwiklabs-gcp-01-ac1b4e1efc06

# Task 3

kubectl create poddisruptionbudget onlineboutique-frontend-pdb --selector app=frontend --min-available 1 --namespace dev

KUBE_EDITOR="nano" kubectl edit deployment/frontend --namespace dev

Replace
image: gcr.io/qwiklabs-resources/onlineboutique-frontend:v2.1
imagePullPolicy: Always

kubectl get pods -l app=frontend --namespace=dev


# Task 4

kubectl autoscale deployment frontend \
    --cpu-percent=50 \
    --min=1 \
    --max=11 \
    --namespace=dev

kubectl get hpa --namespace dev

gcloud beta container clusters update onlineboutique-cluster-156 \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=6 \
    --zone=europe-west4-c


# Optional Task

# Run Load Test with Increased Concurrent Users

kubectl exec $(kubectl get pod --namespace=dev | grep 'loadgenerator' | cut -f1 -d ' ') -it --namespace=dev -- bash -c 'export USERS=8000; locust --host="http://YOUR_FRONTEND_EXTERNAL_IP" --headless -u "8000" 2>&1'

# Apply Horizontal Pod Autoscaling to Recommendationservice Deployment:

kubectl autoscale deployment recommendationservice \
    --cpu-percent=50 \
    --min=1 \
    --max=5 \
    --namespace=dev