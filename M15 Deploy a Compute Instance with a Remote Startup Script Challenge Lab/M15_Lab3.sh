# Create a bucket in Google Cloud Storage
gsutil mb gs://$DEVSHELL_PROJECT_ID

# Get the zone for the project
ZONE="$(gcloud compute instances list --project=$DEVSHELL_PROJECT_ID --format='value(ZONE)' | head -n 1)"

# Download a startup script from GitHub and copy it to your bucket
wget https://github.com/quiccklabs/Labs_solutions/blob/master/Deploy%20a%20Compute%20Instance%20with%20a%20Remote%20Startup%20Script%20Challenge%20Lab/resources-install-web.sh
gsutil cp resources-install-web.sh gs://$DEVSHELL_PROJECT_ID

# Set permissions for the script so that anyone can read it
gsutil acl ch -u AllUsers:R gs://$DEVSHELL_PROJECT_ID/resources-install-web.sh

# Create a Compute Engine instance with specified configurations
gcloud compute instances create lab-monitor-quicklab \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-micro \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=foo=bar,startup-script-url=https://storage.googleapis.com/$DEVSHELL_PROJECT_ID/resources-install-web.sh,startup-script=echo\ Welcome\ to\ Project\ Octopus\ \>\ /tmp/octopus.txt \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --tags=lab-vm,http-server \
  --create-disk=auto-delete=yes,boot=yes,device-name=lab-monitor,image=projects/debian-cloud/global/images/debian-11-bullseye-v20240415,mode=rw,size=100,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-standard \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any

# Create firewall rules to allow HTTP and SSH traffic
gcloud compute firewall-rules create allow-http --allow tcp:80 --target-tags=http-server --description="Allow HTTP traffic to VMs with http-server tag"

gcloud compute firewall-rules create allow-ssh --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0 --target-tags=http-server --description="Allow SSH connections on port 22 from any IP address"

# Reset the Compute Engine instance
gcloud compute instances reset lab-monitor-quicklab --zone $ZONE

# Get the external IP address of the instance
EXTERNAL_IP="$(gcloud compute instances describe lab-monitor-quicklab --project=$DEVSHELL_PROJECT_ID --zone $ZONE --format='value(networkInterfaces[0].accessConfigs[0].natIP)')"

# Add a new startup script to the instance to install Apache
gcloud compute instances add-metadata lab-monitor-quicklab \
  --metadata startup-script='#!/bin/bash
apt-get update
apt-get install -y apache2
' \
  --zone $ZONE

# Reset the instance again to apply the new startup script
gcloud compute instances reset lab-monitor-quicklab --zone $ZONE
sleep 60  # Wait for the instance to reset

# SSH into the instance and check Apache's status
gcloud compute ssh lab-monitor-quicklab --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="curl -I http://$EXTERNAL_IP && sudo systemctl status apache2"
