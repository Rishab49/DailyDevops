# Challenge 01: The Idempotent Deployer
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



# Solution

I have created a script called deploy_site with following logic:

First and foremost I am checking whether user has provided the bucketname or not using the below snippet, if not then I am asking the user to provide one and exiting the script

```bash
if [ -z $1 ]; then
echo "Please enter a bucket name to check"
exit 1
fi
```

Then the requirement is to check:

1. Whether bucket exists or not, if it exists then simply apply the desired settings and print the public s3 website URL

So first I am running the script and capture its ouput and exitcode to evaluate the and make decisions using following snippet

```bash
response=$(aws s3api head-bucket --bucket "$1" 2>&1)
exit_code=$?
```

then I am checking using below snippet whether bucket already exists using the exit code, if it exists then I simply print bucket exists and move futher in execution

```bash
if [ exit_code -eq 0 ]; then
    echo "Bucket already exists"
```

2. if bucket exists but owned by some other user then ssimply print the message and exit the script

For this I am checking whether the script output contains the substring "403", if yes then bucket exists but owned by different user so we are priting the same and exiting the script

```bash
elif echo "$response" | grep -q "403"; then
    echo "Bucket already exists but owned by someone else"
    exit 1

```

3. if it does not exists then create a new bucket and then apply the settings and print the public s3 website url

Finally if none of the above condition satisfies then I'll create a new bucket using following snippet

```bash
else
    echo "Creating bucket"
    aws s3api create-bucket --bucket "$1" --region us-east-1
```


After this we are applying the configurations as instructed inthe challenge statement


- Enable Static Website Hosting on the bucket via the CLI.
For this we have used `aws s3 website s3://$1 --index-document index.html` command which enables the static hosting on the specified website along with the default index document

- Apply a Bucket Policy that allows public read access (GetObject) to the objects. Note: You must handle "Block Public Access" settings to allow this.

For this we have used `aws s3api delete-public-access-block --bucket "$1"` command which will delete the the block public access config from the bucket config and to make the bucket publicly accessible we need to also add a policy which allows public read access to the bucket.

```bash
cat << EOF > policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::$1/*"
    }
  ]
}
EOF
aws s3api put-bucket-policy --bucket "$1" --policy file://policy.json
```

- Upload a dummy index.html file (create this file within the script).
Then we have created a simple html file and upload it to s3 bucket using following command
```bash
cat << EOF > index.html
<h1>Hello world 2</h1>
EOF
```

```bash
aws s3 cp ./index.html s3://$1/
```


- Output: The script must output the final S3 Website URL to the terminal.
Finally we are priting S3 website url and cleaning up the policy and html files

```bash
echo "http://$1.s3-website-us-east-1.amazonaws.com"
rm index.html policy.json
```



The deploy_site script is `idempotent` as no matter how many times you run the script with same bucket name you will get the same output.








