# SRE K3s Challenge – Complete Project Explanation
### Prepared for Technical Interview | Author: Rajat Mehta

---

## Table of Contents

1. [What is this Project?](#1-what-is-this-project)
2. [Why was this Project Built?](#2-why-was-this-project-built)
3. [Technology Stack – What and Why](#3-technology-stack--what-and-why)
4. [Project Structure Overview](#4-project-structure-overview)
5. [Part 1 – Infrastructure Provisioning with Terraform (AWS)](#5-part-1--infrastructure-provisioning-with-terraform-aws)
6. [Part 2 – K3s Kubernetes Cluster Setup](#6-part-2--k3s-kubernetes-cluster-setup)
7. [Part 3 – Kubernetes Application Deployment](#7-part-3--kubernetes-application-deployment)
8. [Part 4 – CI/CD Pipeline with GitHub Actions](#8-part-4--cicd-pipeline-with-github-actions)
9. [Security Considerations](#9-security-considerations)
10. [End-to-End Flow – How Everything Connects](#10-end-to-end-flow--how-everything-connects)
11. [Key DevOps Concepts Demonstrated](#11-key-devops-concepts-demonstrated)
12. [Validation and Verification Commands](#12-validation-and-verification-commands)
13. [Possible Interview Questions and Answers](#13-possible-interview-questions-and-answers)

---

## 1. What is this Project?

This project is an **end-to-end DevOps / SRE (Site Reliability Engineering) challenge** that demonstrates how to:

- **Automatically provision cloud infrastructure** on AWS using Terraform
- **Install and configure a lightweight Kubernetes cluster** called K3s on that infrastructure
- **Deploy a containerized web application** (Nginx serving a "Hello World" HTML page) to that Kubernetes cluster
- **Automate future deployments** using a CI/CD pipeline built on GitHub Actions

In simple terms:

> Whenever a developer pushes code to GitHub, the system automatically picks that change, connects to the Kubernetes cluster running on AWS, applies the latest configuration, and restarts the application — all without any manual steps.

This is a **real-world SRE practice** that demonstrates automation, repeatability, and modern cloud-native deployment patterns.

---

## 2. Why was this Project Built?

This project was built as part of an **SRE (Site Reliability Engineering) hiring challenge** by DigitalXC. The objective was to:

- Show **Infrastructure as Code (IaC)** skills using Terraform
- Demonstrate **Kubernetes (K8s) administration** knowledge
- Implement a **CI/CD pipeline** for automated deployments
- Follow **GitOps principles** — where Git is the single source of truth for both infrastructure and application configuration
- Showcase **DevOps best practices** like secret management, automated provisioning, and reproducible deployments

---

## 3. Technology Stack – What and Why

| Technology | Role | Why it was chosen |
|---|---|---|
| **Terraform** | Infrastructure provisioning | Industry standard IaC tool; declarative, reproducible, cloud-agnostic |
| **AWS** | Cloud provider | Most widely used cloud platform; EC2 for virtual machines |
| **Ubuntu 24.04** | Server OS | Stable, LTS, widely supported Linux distribution |
| **K3s** | Kubernetes distribution | Lightweight Kubernetes — perfect for single-node/edge deployments |
| **containerd** | Container runtime | Default and built-in runtime for K3s |
| **Nginx** | Web server / App | Simple, lightweight web server ideal for containerized deployments |
| **Kubernetes YAML Manifests** | App configuration | Standard Kubernetes way to define desired state of applications |
| **GitHub Actions** | CI/CD pipeline | Native to GitHub; easy to configure, free for public repos |
| **GitHub Secrets** | Secret management | Secure storage of sensitive credentials (like kubeconfig) |

---

## 4. Project Structure Overview

```
sre-k3s-challenge/
|
|-- terraform/               <- Cloud Infrastructure code (AWS resources)
|   |-- provider.tf          <- AWS provider configuration
|   |-- networking.tf        <- VPC, Subnet, Internet Gateway, Route Table
|   |-- security.tf          <- Security Group (firewall rules)
|   |-- ec2.tf               <- EC2 instance (the actual server)
|   |-- variables.tf         <- Input variables (instance type, key name)
|   |-- outputs.tf           <- Outputs (server public IP after creation)
|   `-- userdata.sh          <- Startup script to auto-install K3s on server boot
|
|-- kubernetes/              <- Kubernetes application configuration
|   |-- namespace.yaml       <- Isolated environment for the app
|   |-- configmap.yaml       <- Stores the HTML content served by Nginx
|   |-- deployment.yaml      <- Defines how Nginx should run as a container
|   `-- service.yaml         <- Exposes the app to the internet via NodePort
|
|-- .github/
|   `-- workflows/
|       `-- deploy.yml       <- GitHub Actions pipeline (CI/CD automation)
|
|-- docs/
|   |-- architecture-diagram.png  <- Visual architecture of the system
|   |-- deployment-evidence.md    <- Written proof of successful deployment
|   `-- screenshots/              <- Visual evidence of each step
|
`-- README.md                <- Project documentation
```

---

## 5. Part 1 – Infrastructure Provisioning with Terraform (AWS)

### What is Terraform?

Terraform is an **Infrastructure as Code (IaC)** tool by HashiCorp. Instead of manually clicking through the AWS console to create servers, we write code that describes what infrastructure we want, and Terraform creates it automatically.

**Key benefit:** The infrastructure is reproducible. Anyone with the same code can recreate the exact same infrastructure in minutes.

---

### File: terraform/provider.tf

**What it does:**
- Declares that we are using **Terraform version 1.5 or higher**
- Declares the **AWS provider** (the plugin that lets Terraform talk to AWS)
- Sets the AWS **region to ap-south-2** (Hyderabad, India)

---

### File: terraform/variables.tf

**What it does:**
- Defines **input variables** so that values can be customized without changing the core code
- instance_type defaults to t3.medium — a general-purpose AWS EC2 instance with 2 vCPUs and 4 GB RAM (appropriate for running K3s)
- key_name holds the name of the **SSH key pair** used to securely log into the server

---

### File: terraform/networking.tf

This file sets up the complete networking layer on AWS.

**Resources Created:**

| Resource | Purpose |
|---|---|
| aws_vpc | Virtual Private Cloud — our isolated private network on AWS |
| aws_subnet | A subdivision of the VPC; map_public_ip_on_launch=true means EC2 gets a public IP automatically |
| aws_internet_gateway | Acts as the "door" between our VPC and the internet |
| aws_route_table | Routing rules — sends all traffic (0.0.0.0/0) to the internet gateway |
| aws_route_table_association | Links the route table to the subnet |

---

### File: terraform/security.tf

**What it does:**
- Creates a **Security Group** (AWS firewall) with specific inbound port rules

| Port | Purpose |
|---|---|
| 22 | SSH — to log into the server manually |
| 6443 | Kubernetes API — GitHub Actions uses this to deploy apps |
| 30080 | NodePort — public access to the running application |
| 80 | Standard HTTP port |

---

### File: terraform/ec2.tf

**What it does:**
- Uses a data source to **dynamically fetch the latest Ubuntu 24.04 AMI** (Amazon Machine Image — the OS template)
- Creates an **EC2 instance** (Linux virtual machine) with Ubuntu 24.04, t3.medium size, SSH key, public subnet, and security group
- Runs a **user_data bootstrap script** automatically when the server first boots

---

### File: terraform/userdata.sh

**What it does — Step by Step:**

1. apt update — refreshes the package list
2. apt install curl wget git — installs essential tools
3. curl -sfL https://get.k3s.io | sh — **downloads and installs K3s** (lightweight Kubernetes) in one command
4. systemctl enable k3s — ensures K3s starts automatically on every server reboot
5. systemctl start k3s — starts K3s immediately

---

### File: terraform/outputs.tf

**What it does:**
- After Terraform finishes creating everything, it prints the **public IP address** of the EC2 instance
- This IP is used to access the application at http://PUBLIC_IP:30080

---

### How to Run Terraform

```bash
cd terraform
terraform init              # Downloads AWS provider plugin
terraform plan              # Shows what will be created (dry-run, no changes made)
terraform apply -auto-approve  # Actually creates the infrastructure on AWS
```

---

## 6. Part 2 – K3s Kubernetes Cluster Setup

### What is Kubernetes?

Kubernetes (K8s) is an **open-source container orchestration system**. It automates the deployment, scaling, and management of containerized applications.

Think of it as a **manager** that ensures your containers (Docker/containerd) are always running, healthy, and can be updated without downtime.

### What is K3s?

K3s is a **lightweight, production-ready distribution of Kubernetes** made by Rancher (now SUSE). It is designed for:
- Edge computing
- IoT devices
- CI environments
- Single-node clusters (like this project)

**K3s vs Full Kubernetes Comparison:**

| Feature | Full Kubernetes | K3s |
|---|---|---|
| Binary size | ~500 MB | ~50 MB |
| RAM usage | High (2+ GB) | Low (~512 MB) |
| Setup complexity | Complex, multi-step | Single command install |
| Use case | Large multi-node clusters | Small, edge, single-node |

**After K3s is installed**, verify with:
```bash
sudo kubectl get nodes
# Output: k3s-server   Ready   control-plane
```

The K3s kubeconfig file (cluster access credentials) is at:
```
/etc/rancher/k3s/k3s.yaml
```

This file is copied and stored in **GitHub Secrets** to allow the CI/CD pipeline to connect to the cluster remotely.

---

## 7. Part 3 – Kubernetes Application Deployment

The application is deployed using **4 YAML manifest files**, each representing a different Kubernetes resource.

---

### File: kubernetes/namespace.yaml

**What it does:**
- Creates a **Namespace** called hello-world
- A Namespace is a **logical boundary** inside a Kubernetes cluster
- All application resources (pods, services, configmaps) live inside this namespace
- It prevents conflicts with other applications running on the same cluster

---

### File: kubernetes/configmap.yaml

**What it does:**
- A **ConfigMap** stores non-sensitive configuration data as key-value pairs
- Here, the HTML content of the web page is stored as index.html
- This ConfigMap is later **mounted as a file** inside the Nginx container
- This way, the HTML content is **externalized from the container image** — you can update the page content without rebuilding the Docker image

---

### File: kubernetes/deployment.yaml

**What it does:**
- A **Deployment** is the core Kubernetes resource that manages running containers (called Pods)
- replicas: 1 — we want exactly 1 running instance of Nginx
- image: nginx:latest — uses the official Nginx container image from Docker Hub
- containerPort: 80 — Nginx listens on port 80 inside the container

**Health Probes Explained:**

| Probe | Purpose |
|---|---|
| readinessProbe | "Is this container ready to receive traffic?" If it fails, traffic is not sent to it |
| livenessProbe | "Is this container still alive?" If it fails repeatedly, the container is restarted |

Both probes send an HTTP GET request to / on port 80. If Nginx responds with 200 OK, the container is healthy.

**Volume Mount Explained:**
- volumes section: defines a volume named html-volume sourced from the nginx-html ConfigMap
- volumeMounts section: mounts index.html from that volume directly into Nginx's web root (/usr/share/nginx/html/index.html)
- Result: When Nginx serves content, it serves our custom "Hello World" HTML page from the ConfigMap

---

### File: kubernetes/service.yaml

**What it does:**
- A **Service** is a stable networking endpoint that exposes pods to the outside world
- selector: app: hello-nginx — routes traffic to all pods with this label
- type: NodePort — exposes the service on a fixed port on the node (server)
- nodePort: 30080 — the application is accessible at http://SERVER_IP:30080

**Kubernetes Service Types Comparison:**

| Type | Access Level | Use Case |
|---|---|---|
| ClusterIP | Internal only | Inter-service communication within cluster |
| NodePort | Via node IP and port | Development / testing (used in this project) |
| LoadBalancer | Via cloud load balancer | Production on AWS / GCP / Azure |

---

## 8. Part 4 – CI/CD Pipeline with GitHub Actions

### What is CI/CD?

- **CI (Continuous Integration):** Automatically testing and validating code when pushed to a repository
- **CD (Continuous Deployment):** Automatically deploying the validated code to the target environment

**GitHub Actions** is GitHub's built-in CI/CD platform. Workflows are defined as YAML files in .github/workflows/.

---

### File: .github/workflows/deploy.yml

**Trigger:** This pipeline runs **automatically** whenever code is pushed to the main branch.

**Step-by-step explanation:**

| Step | What it does |
|---|---|
| Checkout Code | Downloads the latest code from GitHub onto the runner machine |
| Install kubectl | Installs the Kubernetes CLI tool on the runner |
| Configure kubeconfig | Decodes the base64-encoded kubeconfig from GitHub Secrets and writes it to ~/.kube/config so kubectl can authenticate with K3s |
| Verify Cluster | Runs kubectl get nodes to confirm cluster is reachable and healthy |
| Deploy Kubernetes Resources | Applies all YAML files in kubernetes/ folder — creates or updates all resources |
| Restart Deployment | Forces a rolling restart so latest configmap changes are picked up by pods |
| Wait For Rollout | Waits up to 120 seconds for new pods to be running; fails pipeline if they don't |
| Verify Pods | Shows the final running state of pods as deployment confirmation |

---

### How GitHub Secrets are Used

**The Problem:** The kubeconfig file contains cluster credentials (API server address, certificates, tokens). We cannot commit this to GitHub.

**The Solution:** Store it as a **GitHub Secret**.

Manual steps performed once:
1. SSH into the EC2 instance
2. Copy the K3s kubeconfig: sudo cat /etc/rancher/k3s/k3s.yaml
3. Base64 encode it: base64 k3s.yaml
4. Store the base64 string in GitHub -> Settings -> Secrets and variables -> Actions -> KUBECONFIG_DATA

In the pipeline, it is decoded at runtime:
```bash
echo "${{ secrets.KUBECONFIG_DATA }}" | base64 -d > ~/.kube/config
```

---

## 9. Security Considerations

| Security Practice | Implementation |
|---|---|
| No hardcoded secrets | Kubeconfig stored in GitHub Secrets, not in code |
| Principle of Least Privilege | Specific firewall rules — only required ports are open |
| Infrastructure as Code | All changes tracked in Git — full audit trail |
| Automated deployments | Less human intervention means fewer human errors |
| Encrypted credentials | GitHub Secrets are AES-256 encrypted |
| SSH key-based auth | Key pair (.pem file) used for EC2 access, not passwords |

**What can be improved for a production environment:**
- Restrict port 22 and 6443 to specific IP ranges (not 0.0.0.0/0)
- Use RBAC (Role-Based Access Control) in Kubernetes to limit CI/CD pipeline permissions
- Use a dedicated service account token for CI/CD instead of the full admin kubeconfig
- Enable TLS/HTTPS for Nginx using cert-manager and Let's Encrypt
- Store sensitive app configurations in Kubernetes Secrets, not ConfigMaps
- Store Terraform state in S3 with DynamoDB locking for team collaboration

---

## 10. End-to-End Flow – How Everything Connects

```
STEP 1: Developer writes code and pushes to GitHub (main branch)
           |
           v
STEP 2: GitHub Actions pipeline is triggered automatically
           |
           v
STEP 3: Runner checks out latest code from the repository
           |
           v
STEP 4: Runner installs kubectl CLI tool
           |
           v
STEP 5: Runner decodes KUBECONFIG_DATA secret
         and configures access to the K3s cluster on AWS EC2
           |
           v
STEP 6: Runner verifies the K3s cluster is healthy (kubectl get nodes)
           |
           v
STEP 7: Runner applies all Kubernetes manifests (kubectl apply -f kubernetes/)
         |-- namespace.yaml    -> Creates/updates the hello-world namespace
         |-- configmap.yaml    -> Updates the HTML content stored in K8s
         |-- deployment.yaml   -> Creates/updates the Nginx deployment
         `-- service.yaml      -> Creates/updates the NodePort service on port 30080
           |
           v
STEP 8: Runner restarts the deployment so pods pick up the latest configmap
           |
           v
STEP 9: Runner waits for the rolling update to complete successfully (max 120s)
           |
           v
STEP 10: Users access the updated app at http://EC2_PUBLIC_IP:30080
```

---

## 11. Key DevOps Concepts Demonstrated

| Concept | How it is demonstrated in this project |
|---|---|
| Infrastructure as Code (IaC) | All AWS infrastructure defined in Terraform HCL files — no manual clicking |
| GitOps | Git is the single source of truth; changes in Git drive both infra and app updates |
| Kubernetes Administration | Namespace, Deployment, Service, ConfigMap, health probes, and volume mounts |
| Container Orchestration | K3s manages the full lifecycle of the Nginx container |
| CI/CD Automation | GitHub Actions auto-deploys on every push to the main branch |
| Secret Management | Kubeconfig stored in GitHub Secrets, decoded securely at runtime |
| Rolling Updates | kubectl rollout restart ensures zero-downtime deployments |
| Configuration Externalization | HTML content in ConfigMap — not baked into the container image |
| Automated Provisioning | Server is self-configuring via EC2 userdata bootstrap script |
| Idempotency | kubectl apply and terraform apply are safe to run multiple times — no duplicate resources |

---

## 12. Validation and Verification Commands

After deployment, use these commands to verify everything is working:

```bash
# 1. Verify the K3s node is in Ready state
kubectl get nodes
# Expected: k3s-server   Ready   control-plane

# 2. Verify pods are in Running state
kubectl get pods -n hello-world
# Expected: hello-nginx-xxxx   1/1   Running

# 3. Verify the service and NodePort assignment
kubectl get svc -n hello-world
# Expected: hello-nginx-service   NodePort   <IP>   80:30080/TCP

# 4. Verify the deployment health
kubectl get deployment -n hello-world
# Expected: hello-nginx   1/1   1   1

# 5. Access the application in browser
http://<EC2_PUBLIC_IP>:30080
# Expected: Hello World page displayed in browser
```

---
