set -e

echo "===================> Building environment_resources for $ENVIRONMENT"
cd "$CODEBUILD_SRC_DIR/environment_resources"
terraform init -no-color
terraform workspace select "$ENVIRONMENT" -no-color
terraform validate -no-color
terraform init -no-color
 
echo "===========> Generating plan"
terraform plan -no-color -out=plan.bin

if [ -f plan.bin ]; then
    echo "===========> Applying changes on the plan"
    terraform apply -auto-approve -no-color -input=false plan.bin
else
    echo "!!!!!!!!!!!!! Plan not found!"
fi
