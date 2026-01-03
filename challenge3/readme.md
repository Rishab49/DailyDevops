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

# Solution

The primary requirement of this challenge is to createee workflow.yaml and main.tf.

## Workflow.yaml

First I have created the workflow.yaml, one of the main thing of workflow is authentication with AWS so that we can run our terraform command, for authentication I have OIDC, below are few useful links

https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws

https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/

Inside workflow are are only checking out the challeneg3 folder and then running the `aws-actions/configure-aws-credentials@v1.7.0` action which uses the IAM role for which we have configured OIDC to request a temporary token to use for this session

```yaml

 - name: "configure aws credentials"
        uses: aws-actions/configure-aws-credentials@v1.7.0
        with:
          role-to-assume: arn:aws:iam::814257528178:role/role-challenge2 
          role-session-name: GitHub_to_AWS_via_FederatedOIDC
          aws-region: "us-east-1"

```

then we are priting the role details which is used for authentication

```yaml
 - name: Sts GetCallerIdentity
        run: |
          aws sts get-caller-identity
```

then we are running `terraform init` and after that we are checking the formatting of the config file and then planning and creating our infra.


## main.tf

Then i have created main.tf one of the main learning is I am using remote bucket to store the terraform state which can be achieved by adding thge below config and making sure the user/role which is used for authentication is having necessary permissions to access the bucket.

```yaml
 backend "s3" {
    region = "us-east-1"
    bucket = "rajrishab-challenge2"
    key    = "state"
  }
```




