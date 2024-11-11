# ==============================================
# Terraform Commands Reference Guide
# ==============================================

# ----------------
# Basic Commands
# ----------------
# Initialize Terraform
terraform init

# Format code
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# Show providers
terraform providers

# Show version
terraform version

# ----------------
# Planning & Applying
# ----------------
# Plan with variables file
terraform plan --var-file="dev.tfvars"

# Plan and save to file
terraform plan -out=plan.tfplan

# Apply with auto-approve
terraform apply --auto-approve --var-file="dev.tfvars"

# Apply specific resource
terraform apply -target=aws_instance.public[0]

# Apply saved plan
terraform apply plan.tfplan

# ----------------
# State Management
# ----------------
# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.public[0]

# Move resource in state
terraform state mv aws_instance.old aws_instance.new

# Remove resource from state
terraform state rm aws_instance.public[0]

# Pull remote state
terraform state pull

# Push state to remote
terraform state push

# Replace provider
terraform state replace-provider hashicorp/aws registry.custom.com/aws

# ----------------
# Workspace Management
# ----------------
# List workspaces
terraform workspace list

# Create workspace
terraform workspace new dev

# Select workspace
terraform workspace select prod

# Delete workspace
terraform workspace delete old-workspace

# Show current workspace
terraform workspace show

# ----------------
# Import & Export
# ----------------
# Import existing resource
terraform import aws_instance.public i-1234567890abcdef0

# Generate configuration
terraform import-configuration aws_instance.public i-1234567890abcdef0

# ----------------
# Destroy Resources
# ----------------
# Destroy all resources
terraform destroy --auto-approve --var-file="dev.tfvars"

# Destroy specific resource
terraform destroy -target=aws_instance.public[0]

# ----------------
# Taint & Untaint
# ----------------
# Mark resource for recreation
terraform taint aws_instance.public[0]

# Remove taint
terraform untaint aws_instance.public[0]

# ----------------
# Output Management
# ----------------
# Show all outputs
terraform output

# Show specific output
terraform output instance_ip

# ----------------
# Debug & Logging
# ----------------
# Enable debug logging
export TF_LOG=DEBUG

# Set log file
export TF_LOG_PATH=terraform.log

# Clear log settings
unset TF_LOG TF_LOG_PATH

# ----------------
# Common Use Cases
# ----------------
# Initial Setup
terraform init
terraform fmt
terraform validate
terraform plan --var-file="dev.tfvars"
terraform apply --var-file="dev.tfvars" --auto-approve

# Update Infrastructure
terraform plan --var-file="dev.tfvars"
terraform apply --var-file="dev.tfvars" --auto-approve

# Update Specific Resource
terraform apply -target=null_resource.update_instances --var-file="dev.tfvars" --auto-approve

# Switch Environments
terraform workspace select prod
terraform apply --var-file="prod.tfvars" --auto-approve

# Destroy Test Environment
terraform workspace select dev
terraform destroy --var-file="dev.tfvars" --auto-approve

# ----------------
# Best Practices
# ----------------
# Before applying changes
terraform fmt
terraform validate
terraform plan --var-file="dev.tfvars"

# Save plan for review
terraform plan --var-file="dev.tfvars" -out=plan.tfplan
terraform show plan.tfplan

# Apply saved plan
terraform apply plan.tfplan

# ----------------
# Maintenance Tasks
# ----------------
# Refresh state
terraform refresh --var-file="dev.tfvars"

# Clean up files
rm -rf .terraform/
terraform init

# Update providers
terraform init -upgrade

# ----------------
# Testing Changes
# ----------------
# Create test workspace
terraform workspace new test

# Apply with test variables
terraform apply --var-file="test.tfvars"

# Verify changes
terraform show
terraform output

# Cleanup test
terraform destroy --auto-approve
terraform workspace select dev
terraform workspace delete test

# ----------------
# Important Notes
# ----------------
# 1. Always use version control
# 2. Keep sensitive data in encrypted files
# 3. Use workspaces for different environments
# 4. Backup state files
# 5. Test changes in non-production first
# 6. Use variables files for different environments
# 7. Document your configurations
# 8. Use consistent naming conventions
# 9. Implement proper state locking
# 10. Regular state backups

# These commands help you:
# - Manage infrastructure
# - Handle different environments
# - Troubleshoot issues
# - Maintain state
# - Update resources
# - Clean up resources
# - Import existing infrastructure
# - Test changes safely

# ----------------
# Environment Variables
# ----------------
# AWS Credentials
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_DEFAULT_REGION="us-east-1"

# Terraform Variables
export TF_VAR_environment="dev"
export TF_CLI_ARGS="-var-file=dev.tfvars"
export TF_WORKSPACE="dev"

# ----------------
# End of Reference
# ---------------- 