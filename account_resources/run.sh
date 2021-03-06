set -e

echo "===================> Building account_resources"
cd "$CODEBUILD_SRC_DIR/account_resources"
terraform init -no-color
terraform validate -no-color

echo "===========> Generating plan"
terraform plan -no-color -out=plan.bin

if [ -f plan.bin ]; then
    echo "===========> Applying changes on the plan"
    terraform apply -auto-approve -no-color -input=false plan.bin
else
    echo "!!!!!!!!!!!!! Plan not found!"
fi
