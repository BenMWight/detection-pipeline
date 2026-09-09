# Detection as Code

A pipeline that keeps detection rules in version control, proves each one still
fires on the behaviour it claims to catch, and deploys them to Microsoft
Sentinel by code.

> **Status: Phase 0 complete.** Scaffold only. Phases 1 to 6 are the work.

## Why

A detection rule that stops working does not announce itself. It goes quiet,
and quiet looks exactly like "no malicious activity." Teams find out during an
incident, when the rule they believed covered a technique turns out to have
been broken for months.

This pipeline makes that failure visible: every rule ships with test cases, and
a rule that stops matching fails the build instead of failing silently in
production.

*(Rewrite this section in your own words in Phase 6. It is graded, and it is
the first thing a hiring manager reads.)*

## Architecture

```
detections/*.yml          Sigma rules, one per detection
        |
        v
   CI: validate  ->  convert to KQL  ->  test against cases  ->  report
        |
        v
   terraform/             deploys rules into Sentinel as analytics rules
```

## Layout

| Path | Contents |
|---|---|
| `detections/` | Sigma rule sources. See `TEMPLATE.yml` for required fields |
| `tests/` | Positive and near-miss cases, one directory per rule |
| `tools/` | Validation, conversion, test execution, test generation |
| `terraform/` | Workspace, Sentinel onboarding, analytics rules |
| `.github/workflows/` | CI definition |
| `docs/` | AI threat model, test generation log |

## Running it

```bash
pip install -r requirements.txt

# validate and test locally before pushing
python tools/validate.py detections/
python tools/test_rules.py

# deploy
cd terraform
cp terraform.tfvars.example terraform.tfvars   # edit the workspace name
terraform init
terraform plan
terraform apply
```

Tear down when finished:

```bash
terraform destroy
```

## Terraform state

**TODO Phase 4:** state currently local. Say here where state lives and why you
chose that. Criterion 4 assesses whether this was a decision or an accident.

## Cost

The workspace has a 1 GB/day ingestion cap set in `variables.tf`. Leave it on.
Set an Azure budget alert before your first `apply`, and destroy the workspace
when you finish.

## Limitations

**TODO Phase 6.** State them honestly. An acknowledged gap costs nothing. A gap
you conceal that a reviewer finds costs a great deal.
