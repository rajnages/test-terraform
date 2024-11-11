# creation for
# vpc boundary
# public(3) and private(3) subnets
# internet gateway(1)
# route tables(2)
# security groups(1)
# ec2 instances(3)
# terraform apply \
# -target=null_resource.update_instances[0] \
# --var-file="dev.tfvars" \              
# --auto-approve
