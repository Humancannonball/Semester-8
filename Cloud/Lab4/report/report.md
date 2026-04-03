---
title: "Laboratory Work 04 — Docker and Podman on Azure"
subtitle: "Integrated Services Networks and Cloud Technologies"
author: "Mark"
date: "2026-04-03"
---

# Objective

The objective of this laboratory work was to get familiar with container runtime platforms, specifically **Docker** and **Podman**, by preparing a Linux virtual machine on Azure and performing the required container lifecycle, networking, and image-building tasks.

> **Note:** Instead of manually creating the VM in the Azure portal, the environment was provisioned with **OpenTofu/Terraform** and configured automatically with `cloud-init`.

# 1. Environment Preparation

The lab environment was deployed to Azure in the `swedencentral` region using Infrastructure as Code. The following resources were created in the `Containers_group` resource group:

| Resource | Name | Region |
|---|---|---|
| Public IP | `mark-docker-pip` | swedencentral |
| Network Security Group | `mark-docker-nsg` | swedencentral |
| Virtual Network | `mark-docker-vnet` | swedencentral |
| Network Interface | `mark-docker-nic` | swedencentral |
| Virtual Machine | `mark-docker-vm` | swedencentral |
| OS Disk | `mark-docker-osdisk` | swedencentral |

VM connection details during the lab:

- DNS: `mark-docker-e72aab.swedencentral.cloudapp.azure.com`
- Public IP: `20.91.207.211`
- VM size: `Standard_B1s`
- OS: Ubuntu 22.04 LTS

The VM was configured automatically to install:

- Docker `28.2.2`
- Podman `3.4.4`
- Git
- Curl

# 2. Work Progress

## 2.1 Docker Installation Check

Verified Docker installation:

```text
Client 28.2.2 | Server 28.2.2
```

## 2.2 First Docker Container

Executed:

```bash
docker run hello-world
```

Observed result:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

This confirmed that:

- the Docker client could communicate with the daemon;
- the image could be downloaded from Docker Hub;
- the container could start and exit successfully.

## 2.3 Searching the Docker Registry

Executed:

```bash
docker search ubuntu
```

Top search results included official `ubuntu` and related images such as `ubuntu/nginx`, `ubuntu/apache2`, and `ubuntu/prometheus`.

## 2.4 Running Ubuntu and BusyBox Containers

Executed:

```bash
docker container run ubuntu
docker container run busybox
```

Observed behavior:

- both images were downloaded successfully when first used;
- both containers exited immediately after startup.

Explanation:

- `ubuntu` and `busybox` do not keep running by default without a long-lived foreground process or interactive shell;
- once the default command completes, the container stops.

## 2.5 `docker container ls` vs `docker container ls -a`

After starting short-lived containers:

- `docker container ls` showed only currently running containers;
- `docker container ls -a` showed both running and stopped containers.

Observed example:

```text
ls:
CONTAINER ID   IMAGE     COMMAND   CREATED        STATUS                  PORTS     NAMES
ccda4580375a   busybox   "sh"      1 second ago   Up Less than a second             festive_blackwell

ls -a:
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS                              PORTS     NAMES
ccda4580375a   busybox   "sh"          1 second ago    Exited (0) Less than a second ago             festive_blackwell
7b773cc49168   ubuntu    "/bin/bash"   4 seconds ago   Exited (0) 3 seconds ago                      vigilant_rosalind
```

Difference:

- `ls` shows only active containers;
- `ls -a` includes stopped containers too.

## 2.6 Interactive Mode (`-i` and `-t`)

Executed over SSH with forced TTY allocation:

```bash
docker run --rm -it busybox sh -lc "echo tty-check; tty; exit"
```

Observed:

```text
tty-check
/dev/pts/0
```

Meaning of the flags:

- `-i` keeps STDIN open for interaction;
- `-t` allocates a pseudo-terminal.

Together, `-it` allows an interactive shell session inside the container.

## 2.7 Viewing Running Containers and Resource Usage

Started a background BusyBox container:

```bash
docker run -d --name busybox-sleeper busybox sh -c 'sleep 180'
```

Checked running containers:

```text
CONTAINER ID   IMAGE     COMMAND               CREATED        STATUS                  PORTS     NAMES
38f6b90b130d   busybox   "sh -c 'sleep 180'"   1 second ago   Up Less than a second             busybox-sleeper
```

Checked live resource usage:

```text
CONTAINER ID   NAME              CPU %   MEM USAGE / LIMIT   MEM %   NET I/O      BLOCK I/O   PIDS
38f6b90b130d   busybox-sleeper   0.00%   432KiB / 899.4MiB   0.05%   486B / 84B   0B / 0B     1
```

Observation:

- the container consumed very little CPU and memory;
- `docker stats` reports live usage of active containers.

## 2.8 Container Ephemerality

Created a file inside one BusyBox container:

```bash
docker run --name busybox-ephemeral-1 busybox sh -lc 'touch test_failas && ls -la | grep test_failas'
```

Observed:

```text
-rw-r--r--    1 root     root             0 Apr  3 12:53 test_failas
```

Started a new BusyBox container and searched for the same file:

```bash
docker run --name busybox-ephemeral-2 busybox sh -lc 'ls -la | grep test_failas'
```

Observed:

```text
exit=1
```

Conclusion:

- the file was not present in the new container;
- containers are ephemeral by default, and filesystem changes do not automatically persist across separate container instances unless volumes or image commits are used.

## 2.9 Reaching Containerised Services

Started Nginx with port mapping:

```bash
docker run -d --name nginx-test -p 8080:80 nginx
```

Verified locally on the VM:

```text
HTTP/1.1 200 OK
Server: nginx/1.29.7
Content-Type: text/html
```

Verified externally from the workstation:

```text
HTTP/1.1 200 OK
Server: Apache/2.4.66 (Unix)
```

Logical data flow:

```text
Browser / curl
   -> Azure Public IP / DNS
   -> NSG rule allowing TCP 8080
   -> VM NIC
   -> Docker port mapping 8080:80
   -> Container web server on port 80
```

## 2.10 Building a Custom Docker Image

Used the pre-created directory on the VM:

```text
/opt/lab4/apache-demo
```

Dockerfile:

```dockerfile
FROM httpd:2.4
COPY ./public-html/ /usr/local/apache2/htdocs/
```

Built the image:

```bash
docker build -t my-docker-image .
```

Observed:

```text
Successfully built df403212595d
Successfully tagged my-docker-image:latest
```

## 2.11 Running the Custom Image

Executed:

```bash
docker run -dit --name my-container1 -p 8080:80 my-docker-image
```

Verified the custom page:

```text
HTTP/1.1 200 OK
Server: Apache/2.4.66 (Unix)
```

Stopping and deleting the container:

```bash
docker stop my-container1
docker rm my-container1
```

## 2.12 Podman Tasks

Checked Podman:

```text
podman version 3.4.4
```

System information excerpt:

```text
distribution: ubuntu 22.04
cgroupVersion: v2
```

Ran HTTPD with Podman:

```bash
podman run -d --name podman-httpd -p 8080:80/tcp docker.io/library/httpd
```

Observed running container:

```text
CONTAINER ID  IMAGE                           COMMAND           STATUS            PORTS                 NAMES
bcd5b89fe372  docker.io/library/httpd:latest  httpd-foreground  Up 5 seconds ago  0.0.0.0:8080->80/tcp  podman-httpd
```

Verified response:

```text
HTTP/1.1 200 OK
Server: Apache/2.4.66 (Unix)
```

Stopped and removed the Podman container:

```bash
podman stop podman-httpd
podman rm podman-httpd
```

## 2.13 Cleanup

After finishing the lab tasks, the Azure resources were removed with:

```bash
terraform destroy -auto-approve
```

All 11 lab resources were destroyed successfully.

# 3. Questions

## How do you build a container image?

A container image is built from a `Dockerfile` or `Containerfile` using a build command such as:

```bash
docker build -t my-image .
```

The build context includes the Dockerfile and any files copied into the image.

## What are some popular container runtimes?

Popular container runtimes and related tools include:

- Docker
- containerd
- CRI-O
- Podman

## How do you run a Podman container in the background?

Use the `-d` flag:

```bash
podman run -d --name podman-httpd -p 8080:80/tcp docker.io/library/httpd
```

## Can Podman work with Docker images?

Yes. Podman can run images from Docker-compatible registries such as Docker Hub. In this lab, `docker.io/library/httpd` was pulled and run successfully with Podman.

## How do you build an image using Podman?

The syntax is very similar to Docker:

```bash
podman build -t my-image .
```

# Conclusion

The lab successfully demonstrated the full basic container workflow on Azure: Docker installation verification, pulling and running images, inspecting active and stopped containers, understanding ephemerality, publishing container ports, building a custom image, and running an equivalent workload in Podman. The VM and network were provisioned with Infrastructure as Code, the required services were reachable through Azure on port `8080`, and the environment was cleaned up at the end of the work.
