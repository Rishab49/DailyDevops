#!/bin/sh

if [ -z $1 ]; then
echo "Please enter a bucket name to check"
exit 1
fi

response=$(aws s3api head-bucket --bucket "$1" 2>&1)
exit_code=$?

if [ exit_code -eq 0 ]; then
    echo "Bucket already exists"
elif echo "$response" | grep -q "403"; then
    echo "Bucket already exists but owned by someone else"
    exit 1
else
    echo "Creating bucket"
    aws s3api create-bucket --bucket "$1" --region us-east-1
fi


aws s3api delete-public-access-block --bucket "$1"
cat << EOF > index.html
<h1>Hello world 2</h1>
EOF
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
aws s3 cp ./index.html s3://$1/
aws s3 website s3://$1 --index-document index.html
echo "http://$1.s3-website-us-east-1.amazonaws.com"
rm index.html policy.json