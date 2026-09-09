# Tools

| Script | Phase | Purpose |
|---|---|---|
| `validate.py` | 3 | Sigma syntax plus the REQUIRED fields from TEMPLATE.yml |
| `convert.py` | 3 | Sigma to KQL. Non-zero exit on conversion failure |
| `test_rules.py` | 3 | Evaluate converted rules against `tests/`. The graded core |
| `gen_tests.py` | 2 | Call the model with a rule, emit candidate event JSON |

## On `gen_tests.py`

The model generates candidates. You verify and commit them. Log every
acceptance and rejection to `docs/test-generation-log.md` as you go - do not
try to reconstruct it afterwards, it is assessed and it will not be accurate.

Read the API key from an environment variable. A committed key is an automatic
fail on the whole project, and it is graded against your full commit history,
so a key removed in a later commit does not help you.
