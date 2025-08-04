# `cloud-1`

**Cloud-1** is a cloud infrastructure and deployment repository designed to support modern application development, infrastructure-as-code (IaC), and DevOps automation. It serves as a foundational project for managing cloud environments, provisioning resources, and deploying services in a scalable and maintainable way.

## 🌐 Features

* Infrastructure as Code (CDK)
* Ansible-based provisioning & configuration
* Multi-cloud ready (AWS)
* Docker deployment support
* Environment segregation: dev, staging, prod

---

## 📁 Project Structure

```
cloud-1/
│
├── ansible/                 # Ansible playbooks, roles, inventory
│   ├── inventory.ini        # Dynamic inventory file
│   ├── secrets.yml          # Secret file
│   ├── playbooks.yml        # YAML playbooks for provisioning
│   ├── roles/               # Reusable Ansible roles
│   ├── cloud-1.pem
│   └── ansible.cfg          # Ansible configuration
│
├── cdk/                   # IaC: Terraform or similar
├── deploy.sh              # to start
└── docker-compose.yml
```

---

## 🚀 Getting Started

### Prerequisites

* [Docker](https://www.docker.com/)
* [cdk](https://www.cdk.io/)
* [Ansible](https://www.ansible.com/)
* Cloud CLI (AWS CLI)
* Python + Pip (using dynamic inventories or Ansible collections)

---

## ⚙️ Infrastructure Setup

```bash
cdk init
cdk deploy
```

---

## 🛠️ Ansible Usage

Ansible is used for server provisioning, software installation, and post-deployment configuration.

### Directory Structure

* `ansible/inventory/` – inventory files (hosts, groups)
* `ansible/playbooks` – main playbooks
* `ansible/roles/` – modular roles (`wordpress`, `nginx`, `docker`, `app`)

### Example Commands

**Dry run:**

```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --check
```

**Apply:**

```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

**With tags:**

```bash
ansible-playbook -i inventory.ini playbook.yml --tags "web"
```

---

## 📦 Deployment

Deployment uses a combination of Ansible and Docker/Kubernetes:

```bash
make deploy
```
---

## 🔐 Secrets Management

Sensitive variables and secrets are managed via:

* Ansible Vault (`ansible-vault encrypt secrets.yml`)
* Cloud-native secret managers (AWS SSM)
