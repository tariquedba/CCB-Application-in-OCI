# OCI Compute Deployment - 6 Application Servers

Terraform configuration to deploy 6 application servers in OCI Dubai region.

## Prerequisites

1. OCI Account with appropriate permissions
2. OCI CLI configured or API keys
3. Terraform installed (>= 1.0)

## Setup

1. Clone this repository
2. Create `terraform.tfvars` with your OCI credentials
3. Initialize Terraform: `terraform init`
4. Plan deployment: `terraform plan`
5. Apply configuration: `terraform apply`

## Configuration

- **Region**: me-dubai-1
- **Servers**: 6 application servers across 3 availability domains
- **Network**: VCN with public subnet, internet gateway, security lists
- **Security**: SSH key-based authentication, network security groups

## Server Specifications

- 4x VM.Standard.E4.Flex (2 OCPU, 16GB RAM)
- 2x VM.Standard.E4.Flex (4 OCPU, 32GB RAM)
- Oracle Linux 8

## Important Notes

- Update `terraform.tfvars` with your actual OCIDs and keys
- Modify security rules based on your application requirements
- Review and adjust instance shapes as needed
