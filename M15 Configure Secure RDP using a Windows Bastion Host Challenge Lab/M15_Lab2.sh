export ZONE=<YOUR-ZONE>
export REGION=<YOUR_REGION>

# Task 1. Create the VPC network
gcloud compute networks create securenetwork --project=$DEVSHELL_PROJECT_ID --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional

gcloud compute networks subnets create securenetwork-subnet --project=$DEVSHELL_PROJECT_ID --region=$REGION --range=10.0.0.0/24 --stack-type=IPV4_ONLY --network=securenetwork

gcloud compute firewall-rules create allow-rdp --project=$DEVSHELL_PROJECT_ID --network=securenetwork --action=ALLOW --rules=tcp:3389 --source-ranges=0.0.0.0/0 --target-tags allow-rdp-traffic

# Task 2. Deploy your Windows instances and configure user passwords
gcloud compute instances create vm-securehost --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-standard-2 --network-interface=subnet=securenetwork-subnet,no-address --network-interface=subnet=default,no-address --tags=allow-rdp-traffic --image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220513

gcloud compute instances create vm-bastionhost --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-standard-2 --network-interface=subnet=securenetwork-subnet --network-interface=subnet=default,no-address --tags=allow-rdp-traffic --image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220513

# Reset Password for Both VM's
gcloud compute reset-windows-password vm-bastionhost --user app_admin --zone "placeholder"
gcloud compute reset-windows-password vm-securehost --user app_admin --zone "placeholder"

# Task 3. Connect to the secure host and configure Internet Information Server
- Step1: Connect Bastion Host VM using RDP
- Step2: Connect securehost private ip via RDP from bastionhost VM
- Step3: Install IIS server in securehost VM