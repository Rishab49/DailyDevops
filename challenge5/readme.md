# Challenge 05: The Container Orchestrator (EKS)
Scenario: The company has outgrown ASGs and wants to move to Kubernetes. You need to provision a managed cluster and deploy your app there.

Task Requirements:

Infra (Bucket A): Use Terraform to provision an Amazon EKS Cluster with one managed node group (at least 2 t3.medium instances).

Tip: Use the official terraform-aws-modules/eks/aws module to save time, as writing EKS from scratch is very complex.

Orchestration (Bucket B): Write a Kubernetes Deployment manifest (deployment.yaml) and a Service manifest (service.yaml) of type LoadBalancer to expose your app.

Logic (Bucket C): Update your GitHub Action to:

Build the Docker image.

Push it to Amazon ECR (Elastic Container Registry).

Update the Kubernetes deployment with the new image tag using kubectl.

# Solution


