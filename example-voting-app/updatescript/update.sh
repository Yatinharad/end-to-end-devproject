#!/bin/bash
set -x  # Enable debugging and stop execution on error

git clone https://$GITHUB_TOKEN@github.com/Yatinharad/end-to-end-devproject.git

cd end-to-end-devproject/example-voting-app || exit 1
ls -a end-to-end-devproject

# ECR REPO URL
ECR_REPO_URL=(
     "975049911024.dkr.ecr.ap-south-1.amazonaws.com/votecap"
     "975049911024.dkr.ecr.ap-south-1.amazonaws.com/resultcap" 
     "975049911024.dkr.ecr.ap-south-1.amazonaws.com/workercap")
 
echo "Current directory: $(pwd)"

# Images and Tags
IMAGE_TAG=${BUILD_NUMBER}  # Default to 'latest' if BUILD_NUMBER is not set
#IMAGES=("votecap" "resultcap" "workercap")  # Array of image names
DEPLOYMENT_FILES=(
    "example-voting-app/k8s-specifications/vote-deployment.yaml"
    "example-voting-app/k8s-specifications/result-deployment.yaml"
    "example-voting-app/k8s-specifications/worker-deployment.yaml"
)  # Array of corresponding deployment files

# Update and deploy each image
for i in "${!ECR_REPO_URL[@]}"; do
  #IMAGE_NAME="${IMGE[$i]}"
  ECR_IMAGE="${ECR_REPO_URL}:${IMAGE_TAG}"
  DEPLOYMENT_FILE="${DEPLOYMENT_FILES[$i]}"

  if [ -f "$DEPLOYMENT_FILE" ]; then
    # Update the image in the deployment file
    sed -i "s|image:.*|image: ${ECR_IMAGE}|g" "$DEPLOYMENT_FILE"
    echo "Updated deployment file: $DEPLOYMENT_FILE"
    cat "$DEPLOYMENT_FILE"
  else
    echo "Error: Deployment file not found for $IMAGE_NAME at $DEPLOYMENT_FILE!"
    exit 1
  fi
done

# Git operations
git config --global user.email "yatinharad2002@gmail.com"
git config --global user.name "Yatinharad"

git add .
git commit -m "Update Kubernetes manifests for all microservices with DockerHub images"
git push origin main
