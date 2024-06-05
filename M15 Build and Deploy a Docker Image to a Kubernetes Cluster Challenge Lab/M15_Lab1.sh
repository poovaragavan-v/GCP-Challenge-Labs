export ZONE=us-west1-a

# Task 1: Create a Kubernetes Cluster

gcloud container clusters create echo-cluster --num-nodes=2 --machine-type=e2-standard-2 --zone=ZONE

# Task 2: Build a tagged Docker image

gsutil cp gs://[PROJECT_ID]/echo-web.tar.gz .

tar -zxvf echo-web.tar.gz

# Build the Docker image with the tag v1:

cd path/to/extracted/files
docker build -t gcr.io/[PROJECT_ID]/echo-app:v1 .

#Push the Docker image to Google Container Registry (GCR):

docker push gcr.io/[PROJECT_ID]/echo-app:v1

#Task 3: Push the image to the Google Container Registry

# Push the Docker image to GCR with the specified hostname gcr.io:

docker push gcr.io/[PROJECT_ID]/echo-app:v1

# Task 4: Deploy the application to the Kubernetes cluster

kubectl create deployment echo-web --image=gcr.io/[PROJECT_ID]/echo-app:v1 --port=8000

kubectl expose deployment echo-web --type=LoadBalancer --port=80 --target-port=8000

kubectl get deployment echo-web

kubectl get service echo-web