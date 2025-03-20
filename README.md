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

An AWS account with appropriate permissions to create IAM roles, EKS clusters, and VPCs.

### An IAM user: Before starting the setup, ensure an IAM user is created. The name of this IAM user should be specified in terraform.tfvars

Basic knowledge of Terraform and AWS EKS.

## Getting Started

### Clone the Repository:

``` 
git clone https://github.com/caxsolindia/eks-automation.git
```
``` 
cd eks-automation
```

### Configure AWS CLI: Make sure the AWS CLI is configured with the necessary permissions.
```
aws configure
```
### Initialize Terraform: Initialize the project to install necessary providers.
```
terraform init
```
### Apply the Terraform Configuration: Apply the configuration to provision the infrastructure.
```
terraform apply
```
### After success follow below steps for ALB Controller setup. Its One time need to hit the commands.

```
aws eks update-kubeconfig --name <cluster-name>  --region <region>
```




```
## Post-Deployment Configuration

### Create a Service Account for Application

A service account is required for your application to interact with AWS services securely. Below is the YAML configuration to create the service account:

```
cat service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: application-service-account
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<aws-account-id>:role/GitLabCIDemo
```

Save the above configuration in a file named service-account.yaml
Apply the configuration using kubectl

``` kubectl apply -f service-account.yaml ```




### Configure Ingress for Your Application

An ingress resource routes external traffic to services within your Kubernetes cluster. Below is the sample configuration for an ALB ingress:

```
cat ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: alb 
    alb.ingress.kubernetes.io/scheme: internet-facing 
    alb.ingress.kubernetes.io/target-type: ip 
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]' 
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service # Replace with your service name
            port:
              number: 80
```



### Updating aws-auth ConfigMap for Service Account Access


This guide explains how to manually add a new IAM role to the existing aws-auth ConfigMap in your Amazon EKS cluster. This step is required for allowing a service account to connect to the cluster inside a script level in alb-ingress.

Steps to Update aws-auth ConfigMap
1. Check the Existing ConfigMap
Run the following command to view the current configuration:

``` kubectl get cm aws-auth -n kube-system -o yaml ```

2. Edit the ConfigMap
Use the following command to modify the aws-auth ConfigMap:

``` kubectl edit cm aws-auth -n kube-system ```

This will open the ConfigMap in your default text editor.

3. Add the New Role
Scroll to the mapRoles section and add the following lines without removing existing roles:
    - groups:
      - system:masters
      rolearn: arn:aws:iam::xxxxx:role/eks-service-account-role
      username: user
Make sure the indentation matches the existing YAML structure.

4. Save and Exit
In vi editor: Press Esc, type :wq, and hit Enter.
In nano editor: Press Ctrl+X, then Y, and hit Enter.

5. Verify the Changes
Run the following command to confirm the role has been added:

``` kubectl get cm aws-auth -n kube-system -o yaml ```

