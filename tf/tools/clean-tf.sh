#!/usr/bin/env bash

rm -rf .terraform .terraform.lock.hcl terraform.tfstate*

terraform init
