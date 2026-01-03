Challenge 03: The Self-Healing Monitor
Scenario: Your company is moving to a "GitOps-lite" model. You need to deploy a containerized web server and ensure it is automatically monitored.

Task Requirements:

Infra (Bucket A): Create a Terraform configuration (main.tf) to provision:

One AWS EC2 Instance (t2.micro/Amazon Linux 2023).

A Security Group allowing ports 80 (App) and 9090 (Prometheus).

Orchestration (Bucket B): Use a User Data script (passed via Terraform) that:

Installs Docker.

Runs a containerized Nginx web server.

Runs a Prometheus container that is configured to scrape the EC2 instance's metadata or a dummy metric endpoint.

Logic (Bucket C): Write a GitHub Actions Workflow (.github/workflows/deploy.yml) that:

Triggers on push to the main branch.

Runs terraform plan and terraform apply -auto-approve.

Strict Constraint: You must use GitHub Secrets for AWS Credentials.