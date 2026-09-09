# Phase 0 checklist

Scaffold is done. Four things left, roughly 20 minutes.

- [ ] `git init` and first commit, before touching anything else
- [ ] Confirm `.gitignore` is working: `touch terraform/terraform.tfstate`,
      run `git status`, check it does not appear, then delete it
- [ ] `az login`, then `terraform -chdir=terraform init` and
      `terraform plan` - must run clean before you write any resources
- [ ] Azure budget alert set on the subscription

The `terraform plan` step is the real gate. If auth is broken you want to know
now, not at hour eight.

Then start Phase 1.
