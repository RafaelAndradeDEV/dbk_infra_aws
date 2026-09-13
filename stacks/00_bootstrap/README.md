# Stack 00 — Bootstrap

Creates the **S3 bucket that holds the remote Terraform state** for every other stack.

| | |
|---|---|
| **State** | Local file `bootstrap.tfstate` (git-ignored). The remote backend can't store the state of the bucket that holds it |
| **Depends on** | Nothing |
| **Run by CI?** | No. Run it once, by hand |

## Resources

| Resource | Configuration |
|----------|---------------|
| `aws_s3_bucket.tf_state` | Name from `backend_state_bucket_name` in `project_configs.yml`. `force_destroy = true` |
| `aws_s3_bucket_versioning` | Enabled, so earlier state versions can be recovered |
| `aws_s3_bucket_server_side_encryption_configuration` | SSE-AES256 |
| `aws_s3_bucket_public_access_block` | All four flags `true` |

## Usage

```
cd stacks/00_bootstrap
terraform init
terraform apply
```

## Notes

- Keep `bootstrap.tfstate` somewhere safe, for example a password manager or a private bucket. Without it you have to `terraform import` the bucket before changing it again.
- The AWS provider region is hardcoded in `providers.tf` (`us-east-2`). Change it there if you change `aws_region`.
- State locking isn't configured. For team use, add `use_lockfile = true` to the `backend "s3"` blocks of the other stacks (Terraform ≥ 1.10).

Generated reference: [TF_README.md](TF_README.md)
