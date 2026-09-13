# Remote state backend.
#
# Terraform backend blocks cannot use variables/interpolation, so fill in
# the real bucket/table names here (or pass them via `-backend-config`
# flags / a backend.hcl file per environment in Jenkins) before running
# `terraform init`. Replace the placeholder values below.
#
# Recommended key layout so each workspace/environment gets isolated state:
#   key = "vpc/${terraform.workspace}/terraform.tfstate"  (not literally
#   usable here — set a distinct key per env via -backend-config instead).

terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_YOUR_TF_STATE_BUCKET"
    key            = "vpc/terraform.tfstate" # override per env with -backend-config="key=vpc/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REPLACE_WITH_YOUR_TF_LOCK_TABLE"
    encrypt        = true
  }
}
