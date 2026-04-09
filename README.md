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

- Terraform installed
- Ansible installed
- Azure CLI authenticated (`az login`)
- SSH keys at `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`

Required variables:
- `jenkins_account_username`
- `jenkins_account_password`
- `gitlab_stageDevops_commercial_token`
- `gitlab_reclamation_token`


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
