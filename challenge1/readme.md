Challenge 01: The Idempotent Deployer
Scenario: A frontend team needs to deploy a static "Service Status" page. Instead of manual uploads, you must provide a reusable Shell Script that handles the lifecycle of an AWS S3-hosted website.

Task Requirements:

Logic (Bucket C): Create a Shell script named deploy_site.sh.

Infra (Bucket A): The script must:

Accept a unique Bucket Name as a command-line argument.

Check if the S3 bucket already exists. If not, create it in us-east-1.

Enable Static Website Hosting on the bucket via the CLI.

Apply a Bucket Policy that allows public read access (GetObject) to the objects. Note: You must handle "Block Public Access" settings to allow this.

Upload a dummy index.html file (create this file within the script).

Output: The script must output the final S3 Website URL to the terminal.

Strict Constraint: The script must be idempotent. Running it multiple times with the same bucket name should not result in errors or duplicate resource creation.