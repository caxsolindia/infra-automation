# EKS Setup Using Terraform 

This project provides a modular approach to setting up an Amazon EKS cluster using Terraform. The modules are designed to handle the setup of core components such as VPC, EKS cluster, ALB ingress, RBAC, and OIDC configurations. This allows for a scalable and customizable infrastructure that can be easily managed and maintained.



## Overview
This repository provides a complete infrastructure setup for an Amazon EKS cluster using modularized Terraform scripts. Each module is independently responsible for provisioning specific components of the cluster, enabling better modularity and reusability.

## Architecture
<img src="https://github.com/caxsolindia/eks-terraform-module/blob/main/architecuture_diagram/eks_architecture.png" />

## Directory Structure
```
EKS-Terraform-GitHub-Actions/
├── .github/
│   └── workflows/
│       └── terraform.yml
├── modules/
│   ├── add-on/
│   ├── alb-ingress/
│   ├── eks/
│   ├── oidc/
│   ├── rbac/
│   ├── rds/
│   ├── vpc/
├── .gitattributes
├── .gitignore
├── .terraformignore
├── README.md
├── backend.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
└── variables.tf
```
### Prerequisites

Terraform v0.12+

AWS CLI

eksctl cli

Helm CLI

Kubectl CLI


