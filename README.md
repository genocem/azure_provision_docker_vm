# Azure Docker Provisioning
Terraform and Ansible automation for Azure infrastructure: VM provisioning, Docker setup.

TLDR: a way to just create a ready vm to just clone and docker compose up my projects that need to download Gigs of dependencies

ty azure for providing student pack and having fast internet


## Components

- Terraform - Azure VM provisioning
- Ansible - Configuration management
  - Docker installation
  - Git installation
## Prerequisites

### 1. Local Tools
Ensure you have the following installed on your local machine:
- **[Terraform](https://developer.hashicorp.com/terraform/downloads)**
- **[Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)** (including `ansible-playbook`)
- **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)**

### 2. Authentication & Credentials
- **Azure Account**: Authenticate your CLI session by running:
  ```bash
  az login
  ```
- **Azure Subscription**: Export your Subscription ID as an environment variable:
  (If you want this to be a one time thing paste that line in your .bashrc or wherever you usually put environment variables)
  ```bash
  export ARM_SUBSCRIPTION_ID="your_subscription_id_here"
  ```
- **SSH Keys**: The provisioning process requires an SSH key pair securely located at `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`.
  - *If you don't have an SSH key pair, you can generate one using:*
    ```bash
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
    ```


## Usage

```bash
cd terraform
terraform init
terraform apply
# Set ssh_enabled variable to run Ansible configuration
# Ansible runs automatically after VM creation
```
## License

MIT License
