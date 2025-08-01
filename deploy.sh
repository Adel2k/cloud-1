#!/bin/bash

set -e

touch ansible/vault_pass.txt
echo "Deploying infrastructure with CDK..."
cdk deploy --require-approval never > cdk_output.txt

EIP=$(aws ec2 describe-addresses --query 'Addresses[*].PublicIp' --output text)

EIP_DASH="${EIP//./-}"

cat > ansible/inventory.ini <<EOF
[web]
ec2-$EIP_DASH.compute-1.amazonaws.com ansible_user=ubuntu ansible_ssh_private_key_file=./cloud-1.pem
EOF

echo "Running Ansible playbook..."
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --vault-password-file ansible/vault_pass.txt
