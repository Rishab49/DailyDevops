Challenge 04: The Resilient Python Backend
To finish Level 2, we need to move away from a single "pet" EC2 instance and toward a "cattle" approach. This challenge focuses on Scaling and Logic Integration.

Scenario: Your Python app (from Challenge 02) needs to be deployed in a highly available manner.

Task Requirements:

Infra (Bucket A): Update your Terraform to use an Auto Scaling Group (ASG) and an Application Load Balancer (ALB).

The ASG should have a min_size of 1 and max_size of 2.

The ALB should listen on port 80 and forward traffic to the ASG.

Orchestration (Bucket B):

Your user_data should now pull a Docker image.

Self-Correction/Constraint: Since we aren't using a private registry yet, you can use the user_data to build the image locally on the instance using a git clone of your app code.

Logic (Bucket C): Update your GitHub Actions workflow.

New Requirement: Add a "Linting" step for your Python code using flake8 or pylint.

The workflow should only proceed to terraform apply if the Python linting passes.