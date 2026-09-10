# AI threat model

## Trust boundary

The generator reads a Sigma rule file: its description, its detection logic, and
its metadata. It produces JSON test cases which are committed to the repository
and then determine whether a rule passes or fails in CI.

Rule files are the only input, and today they are written by hand by one author.
That keeps the boundary narrow. It widens as soon as rules are authored from
external sources — a vendor report, a public rule set, a threat intel feed —
because rule text then originates outside the trust boundary while flowing into
the same prompt.

## Prompt injection

If rules are ever authored from external threat intelligence, a crafted rule
description becomes attacker-controlled text flowing into the generator's prompt.

The generator cannot alter detection logic, so an attacker cannot inject a
malicious rule. What they can do is influence the test cases: a positive case
that does not actually match the rule, or a near-miss that does. Either one
fails the build. A rule that fails CI does not ship, and the reviewer's likely
response is to weaken the rule until the tests pass.

The result is denial of detection rather than code execution. The pipeline's
safety property — that tests are checked against the rule — is what limits the
blast radius, because a generated case that contradicts the rule is caught.

## Failure modes

| Failure | Does the pipeline detect it? | If not, what would? |
|---|---|---|
| Silent degradation in output quality | No - weaker near-misses still pass the tests | Periodic human review of generated cases |
| Schema drift over time | No - tests match old schema, rule still passes, but misses real events | Validating rules against live telemetry |
| Plausible but wrong test cases | Yes - test_rules.py fails if the generated positive doesn't match the rule | n/a |
| API unavailable | Yes - script errors, no cases returned | n/a |

## Over-reliance

Once committed, a generated test case and a hand-written one look identical, so
a reviewer has no way to tell which have actually been verified. Each test case
now carries a `source` field, set to `handwritten` or `generated`, so provenance
survives into the repository rather than being lost at commit time.

This is a marker, not a control. Nothing enforces that generated cases receive
more scrutiny; it only makes the distinction visible to someone who looks.

## Placement justification

Generation is an acceptable role for the model here because every candidate it
produces is checked by something that is not a model. `test_rules.py` evaluates
each generated case against the rule's own logic, so a wrong case fails visibly
rather than being absorbed.

If the model instead wrote detection logic, or judged whether a rule was
correct, nothing downstream could catch a bad answer, because the model would be
the check.

The principle: a language model is acceptable where its output is verifiable by
something that isn't a language model, and unacceptable where its output is the
final word.

## OWASP LLM Top 10 mapping

| Finding | Category |
|---|---|
| Crafted rule descriptions from external threat intel reach the generator's prompt, influencing test cases to fail a legitimate rule | LLM01: Prompt Injection |
| Generated and hand-written test cases are indistinguishable after commit, so generated ones may be accepted as verified | LLM09: Overreliance |
| Model output quality degrades gradually, producing weaker near-misses that still pass, with nothing flagging the decline | LLM09: Overreliance |
