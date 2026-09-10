# AI threat model (Phase 5)

15 marks for roughly an hour. Highest marks-per-hour in the project.
Reasoning is assessed, not length.

## Trust boundary

What does the model read? What does it produce? Who can influence its input?

## Prompt injection

Rule descriptions are attacker-influenceable if rules are ever authored from
external threat intelligence. What could a crafted description cause the
generator to emit? Be specific to this pipeline, not generic.

## Failure modes

| Failure | Does the pipeline detect it? | If not, what would? |
|---|---|---|
| Silent degradation in output quality | No - weaker near-misses still pass the tests | Periodic human review of generated cases |
| Schema drift over time | No - tests match old schema, rule still passes, but misses real events | Validating rules against live telemetry |
| Plausible but wrong test cases | Yes - test_rules.py fails if the generated positive doesn't match the rule | n/a |
| API unavailable | Yes - script errors, no cases returned | n/a |

## Over-reliance

What stops a reviewer treating generated tests as verified ones?

## Placement justification

Why is generation an acceptable role for the model here, and authoritative
decision-making not? This is the argument the criterion is really testing.

## OWASP LLM Top 10 mapping

| Finding | Category |
|---|---|
| | |
