# OpenTofu Containers Lab — Azure VM with Docker and Podman

> **Laboratory Work 04** — Integrated Services Networks & Cloud Technologies (VilniusTech)

This lab provisions an Ubuntu VM on Azure with Docker and Podman preinstalled, so the container exercises can be completed without using the Azure portal. The infrastructure is defined as code and follows the same OpenTofu/Terraform layout as Labs 1 to 3.

## What Is Automated

- Azure Resource Group
- Virtual network, subnet, NSG, NIC, and public IP
- DNS label for easy SSH and browser access
- Ubuntu 22.04 VM
- Docker, Podman, Git, and Curl installation through cloud-init
- A ready-made Apache demo in `/opt/lab4/apache-demo` for the image-building task

## Project Structure

```text
Lab4/
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── cloud-init.sh
├── README.md
└── 04 - lab - docker EN v2.txt
```

## Quick Start

1. Authenticate with Azure:

```bash
az login
```

2. Create a `terraform.tfvars` file:

```hcl
admin_password = "ChangeMe123!"
```

3. Deploy the lab:

```bash
terraform init
terraform apply
```

4. Connect to the VM:

```bash
ssh -i id_rsa azureuser@<dns_name>
```

## Lab Task Mapping

- Task 1: `terraform apply` replaces the manual VM creation from the PDF.
- Tasks 2 and 3: run the Docker commands directly on the VM.
- Task 4: port `8080` is already opened in the NSG, so published containers are reachable externally.
- Task 5: the Docker build context already exists at `/opt/lab4/apache-demo`.
- Task 6: Podman is preinstalled on the VM.

## Useful Commands On The VM

```bash
docker version
docker run hello-world
docker search ubuntu
docker run -it busybox
docker stats

cd /opt/lab4/apache-demo
docker build -t my-docker-image .
docker run -dit --name my-container1 -p 8080:80 my-docker-image

podman info
podman run -d -p 8080:80/tcp docker.io/library/httpd
podman ps -a
podman images
```

## Cleanup

```bash
terraform destroy
```
