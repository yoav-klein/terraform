
REPOSITORY=$(terraform output -raw repository_url)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $REPOSITORY
