CDK_DIR=cdk
ANSIBLE_DIR=ansible
KEY_PATH=./cloud-1.pem
ANSIBLE_USER=ubuntu

deploy:
	@echo "Running CDK Deploy..."
	cdk deploy --require-approval never > cdk_output.txt
	@$(MAKE) inventory
	@$(MAKE) ansible

inventory:
	@echo "Getting Elastic IP..."
	$(eval EIP=$(shell aws ec2 describe-addresses --query 'Addresses[*].PublicIp' --output text))
	@echo "EIP: $(EIP)"
	@echo "[wordpress]" > $(ANSIBLE_DIR)/inventory.ini
	@echo "cloud1 ansible_host=$(EIP) ansible_user=$(ANSIBLE_USER) ansible_ssh_private_key_file=$(KEY_PATH)" >> $(ANSIBLE_DIR)/inventory.ini

ansible:
	@echo "Running Ansible playbook..."
	ansible-playbook -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbook.yml

clean:
	cdk destroy --force
	rm -f $(ANSIBLE_DIR)/inventory.ini
	rm -f cdk_output.txt
