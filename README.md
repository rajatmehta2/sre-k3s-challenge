# K3s Automated Deployment Challenge

## Project Overview

This project demonstrates the automated provisioning of a Kubernetes environment using K3s and the automated deployment of a simple Nginx-based web application through a GitHub Actions CI/CD pipeline.

The objective of this challenge is to showcase Infrastructure as Code (IaC), Kubernetes deployment automation, and CI/CD implementation using industry-standard DevOps practices.

The solution provisions a Linux server, installs K3s automatically, deploys a containerized Nginx application that serves a custom HTML page, and automatically updates the application whenever changes are pushed to the Git repository.

---

# Solution Architecture

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Actions Pipeline
    │
    ▼
Kubernetes Manifests
    │
    ▼
K3s Cluster
    │
    ▼
Nginx Application
    │
    ▼
Browser Access
```

---

# Technology Stack

| Component                   | Technology               |
| --------------------------- | ------------------------ |
| Infrastructure Provisioning | Terraform                |
| Operating System            | Ubuntu 24.04             |
| Kubernetes Distribution     | K3s                      |
| Container Runtime           | containerd (K3s default) |
| Application                 | Nginx                    |
| CI/CD                       | GitHub Actions           |
| Version Control             | GitHub                   |
| Infrastructure as Code      | Terraform                |
| Kubernetes Resources        | YAML Manifests           |

---

# Project Structure

```text
sre-k3s-challenge/

├── terraform/
│   ├── provider.tf
│   ├── networking.tf
│   ├── security.tf
│   ├── ec2.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── userdata.sh
│
├── kubernetes/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── docs/
│   └── screenshots/
│
└── README.md
```

---

# Implementation Details

## Part 1 – Automated K3s Installation

Terraform is used to provision infrastructure and automatically install the latest stable version of K3s on an Ubuntu server.

### Automated Tasks

* Provision Linux server
* Configure networking and firewall rules
* Install required dependencies
* Install K3s Kubernetes cluster
* Enable and start K3s service
* Configure Kubernetes API access

### Cluster Verification

```bash
sudo kubectl get nodes
```

Expected Output:

```text
NAME           STATUS   ROLES
k3s-server     Ready    control-plane
```

---

## Part 2 – Nginx Application Deployment

A simple Nginx application is deployed to the K3s cluster.

The application serves a static HTML page through Kubernetes.

### Kubernetes Resources

#### Namespace

Provides logical isolation for application resources.

#### ConfigMap

Stores application content (HTML page).

#### Deployment

Manages application pods and ensures desired state.

#### Service

Exposes the application externally through a NodePort.

---

## Application Access

After deployment, the application is accessible using:

```text
http://<SERVER_PUBLIC_IP>:30080
```

Example:

```text
http://18.xxx.xxx.xxx:30080
```

---

# CI/CD Pipeline

GitHub Actions is used to automate application deployment.

The deployment process is triggered automatically whenever code is pushed to the main branch.

## Pipeline Workflow

1. Developer pushes code to GitHub.
2. GitHub Actions pipeline starts automatically.
3. Pipeline authenticates with K3s cluster.
4. Kubernetes manifests are applied.
5. Deployment is restarted automatically.
6. Kubernetes updates the application.
7. Users receive the latest version of the application.

---

## Deployment Workflow

```text
Code Change
     │
     ▼
Git Push
     │
     ▼
GitHub Actions
     │
     ▼
kubectl apply
     │
     ▼
Deployment Restart
     │
     ▼
Updated Application
```

---

# Security Considerations

The following security best practices were implemented:

* Infrastructure managed using Infrastructure as Code (Terraform)
* Kubernetes manifests stored in version control
* No secrets committed to the repository
* Kubeconfig stored securely using GitHub Secrets
* Automated deployment through CI/CD pipeline
* Principle of least manual intervention
* Reproducible and auditable deployment process

---

# How to Deploy

## Step 1 – Clone Repository

```bash
git clone <repository-url>
cd sre-k3s-challenge
```

---

## Step 2 – Deploy Infrastructure

```bash
cd terraform

terraform init

terraform plan

terraform apply -auto-approve
```

---

## Step 3 – Verify K3s

```bash
sudo kubectl get nodes
```

---

## Step 4 – Configure GitHub Secret

Store the K3s kubeconfig in GitHub Actions Secrets.

Secret Name:

```text
KUBECONFIG_DATA
```

---

## Step 5 – Push Changes

```bash
git add .
git commit -m "Application Update"
git push origin main
```

The deployment pipeline will automatically execute.

---

# Validation Commands

## Verify Nodes

```bash
kubectl get nodes
```

## Verify Pods

```bash
kubectl get pods -n hello-world
```

## Verify Services

```bash
kubectl get svc -n hello-world
```

## Verify Deployment

```bash
kubectl get deployment -n hello-world
```

---

# Screenshots

The following screenshots are included as evidence of successful implementation:

| Screenshot                    | Description                         |
| ----------------------------- | ----------------------------------- |
| 01-terraform-apply.png        | Successful Terraform deployment     |
| 02-k3s-running.png            | K3s cluster verification            |
| 03-github-actions-success.png | Successful CI/CD pipeline           |
| 04-pods-running.png           | Running Kubernetes resources        |
| 05-browser-hello-world.png    | Application accessible from browser |

---

# Video Demonstration

The demonstration video covers:

* Infrastructure provisioning using Terraform
* K3s installation verification
* Kubernetes deployment
* GitHub Actions pipeline execution
* Automatic deployment after Git push
* Browser access to the application

Video Link:

```text
<ADD_VIDEO_LINK_HERE>
```

---

# Key DevOps Practices Demonstrated

* Infrastructure as Code (IaC)
* Kubernetes Administration
* Continuous Integration
* Continuous Deployment
* GitOps Workflow
* Configuration Management
* Automated Provisioning
* Secure Secret Handling
* Deployment Automation
* Operational Simplicity

---

# Conclusion

This project successfully demonstrates an end-to-end DevOps workflow that provisions infrastructure, installs K3s, deploys a containerized application, and automates future deployments through a GitHub Actions pipeline.

The implementation follows modern DevOps principles, ensuring repeatability, automation, maintainability, and ease of operation while keeping the overall solution lightweight and efficient.
