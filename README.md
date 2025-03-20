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
git clone https://github.com/caxsolindia/eks-terraform-module.git
```
``` 
cd eks-terraform-module
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


### Install the ALB Ingress Controller [ optinal/ No Need manually to do ]

```
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm search repo eks

helm install alb-ingress-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=alb-ingress-controller \
  --set ingressClass=alb \
  --set vpcID=<vpc-id>

or

helm install alb-ingress-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=edc-dev \
  --set vpcID=vpc-0e3b7551dd34b85c3  \
  --set region=eu-central-1

```

### Verify

```
kubectl logs -f deployment.apps/alb-ingress-controller-aws-load-balancer-controller -n kube-system

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
    kubernetes.io/ingress.class: alb # Specifies the ALB ingress class
    alb.ingress.kubernetes.io/scheme: internet-facing # Makes the ALB public; use "internal" for private ALB
    alb.ingress.kubernetes.io/target-type: ip # Routes traffic to the IPs of pods
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]' # Configures the ALB to listen on port 80
    # alb.ingress.kubernetes.io/subnets: "<subnet-1-id>,<subnet-2-id>" # Replace with your subnet IDs
    # alb.ingress.kubernetes.io/security-groups: "<security-group-id>" # Replace with your ALB security group ID
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

Save the above configuration in a file named ingress.yaml.
Apply the configuration using kubectl

``` kubectl apply -f ingress.yaml ```


Verify the Deployment

Check if the service account has been created successfully:

``` kubectl get serviceaccount application-service-account -n default ```

Verify that the ingress is properly configured and an ALB has been provisioned:

``` kubectl get ingress my-app-ingress -n default ```

Check the logs of the ALB ingress controller to ensure there are no errors:

``` kubectl logs -f deployment.apps/alb-ingress-controller-aws-load-balancer-controller -n kube-system ```



Once the ingress is active, access your application using the external ALB DNS name or IP displayed under kubectl get ingress.

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

You should see the newly added role under mapRoles.

Purpose
Adding this role ensures that the service account has the required permissions to interact with the EKS cluster when used inside scripts for alb-ingress.

