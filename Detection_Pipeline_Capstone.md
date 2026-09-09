# Capstone: Detection as Code

**Security Engineering — Final Project**
Duration: 10 hours. Individual. Deliverable is a public Git repository.

---

## Premise

A detection rule that stops working does not announce itself. It goes quiet, and quiet looks
exactly like "no malicious activity." Teams discover the failure during an incident, when the
rule they believed covered a technique turns out to have been broken for months.

You will build the pipeline that makes this failure mode visible: detections held in version
control, each one accompanied by test cases proving it fires on the behaviour it claims to
catch, deployed to a live SIEM by code, with a build that fails when a rule stops working.

You are not being assessed on the sophistication of your detection logic. Three simple, correct,
well-tested rules score higher than eight clever untested ones.

---

## Learning outcomes

On completion you should be able to:

1. Express detection logic in a portable format and convert it to a platform query language.
2. Justify a detection's true-positive and false-positive profile with evidence, not assertion.
3. Deploy security content to a SIEM using infrastructure as code.
4. Build a CI pipeline that validates security content before it reaches production.
5. Assess where a language model is and is not appropriate inside a security control, and
   document the risks of the placement you chose.

---

## Prerequisites

- Azure subscription with free credit, or an existing tenant you may deploy into.
- GitHub account.
- Terraform, Python 3, and Git installed locally.
- An API key for a language model.

**Cost warning:** a Sentinel workspace ingesting even small volumes will consume credit. Set a
budget alert before you start and destroy the workspace when you finish. Managing this is part of
the exercise; an unbounded spend is an engineering failure, not a footnote.

---

## Phases

### Phase 0 — Setup (0.5 hr)

Create the repository. Establish the structure before writing content:

```
detections/          Sigma rule sources
tests/               Test cases per rule
terraform/           Deployment code
.github/workflows/   CI definition
tools/               Test generation and conversion scripts
docs/                Threat model, findings
README.md
```

Initialise Terraform against your Azure subscription. Confirm you can authenticate and that
`terraform plan` runs clean before you write any resources.

**Checkpoint:** empty repo, working Terraform auth.

---

### Phase 1 — Author three detections (2 hr)

Write three detection rules in Sigma. They must be genuinely different in shape:

- One **atomic** rule — a single event with distinguishing field values.
- One **correlation** rule — a sequence or threshold across multiple events.
- One **anomaly** rule — a deviation from a baseline you define.

For each rule, document in the rule file itself:

- The technique it detects, mapped to MITRE ATT&CK.
- The specific log source and event ID or table it depends on.
- The expected false positive sources, named concretely. "Admin activity" is not an answer.
  "Scheduled backup service account performing bulk reads between 0100 and 0300" is.
- The tuning you would apply and why you have not applied it here.

Rules must be your own work. You may draw on published rule sets for structure, but a copied
rule with a changed title scores zero for this phase and calls the whole submission into
question.

**Checkpoint:** three Sigma files that a peer could read and understand without you present.

---

### Phase 2 — Generate test cases (1.5 hr)

Each rule needs at least two test cases:

- A **positive** event that must trigger the rule.
- A **near-miss** event, similar enough to be plausible, that must not trigger it.

Build a script in `tools/` that calls a language model with the rule as input and returns
structured event JSON matching your log source's schema. The model generates candidates; you
verify and commit them. Some output will be wrong — schema drift, invented field names,
positives that would not actually fire. Finding those is the point.

Record in `docs/` how many generated cases you accepted, how many you rejected, and the failure
modes you saw. This record is assessed.

**Checkpoint:** `tests/` populated, with a written account of what the model got wrong.

---

### Phase 3 — Build the CI pipeline (2 hr)

A GitHub Actions workflow that runs on every push and pull request:

1. **Validate** — Sigma syntax is well formed; required metadata fields are present.
2. **Convert** — transform each rule to KQL. Fail the build on a conversion error.
3. **Test** — evaluate each converted rule against its test cases. The positive must match; the
   near-miss must not. Either outcome failing fails the build.
4. **Report** — a summary of rules validated, converted, and passing.

The test step is the substance of this project. A pipeline that only lints is a linter.

Prove the build fails correctly: open a pull request that breaks a rule, capture the red build,
and reference it in your README. **An unproven pipeline is assumed not to work.**

**Checkpoint:** a green build on main, and a linked red build demonstrating a caught regression.

---

### Phase 4 — Deploy with Terraform (2.5 hr)

Terraform code that provisions:

- A Log Analytics workspace with Sentinel enabled.
- Your three detections as scheduled analytics rules, with query, frequency, period, severity,
  and ATT&CK tactic populated from the Sigma metadata rather than hardcoded.

Requirements:

- State is managed deliberately. Say in your README where state lives and why.
- No secrets in the repository. None. A committed credential is an automatic fail regardless of
  other marks.
- `terraform destroy` returns the subscription to its prior state cleanly.

Evidence: screenshots or CLI output showing the rules present and enabled in the portal.

**Checkpoint:** rules deployed from code, visible in Sentinel, destroyable.

---

### Phase 5 — Threat model the AI component (1 hr)

You placed a language model inside a pipeline that produces security controls. Write
`docs/ai-threat-model.md` covering:

- **Trust boundary.** What does the model read, what does it produce, and who can influence its
  input?
- **Prompt injection.** A rule description is attacker-influenceable if rules are ever authored
  from external threat intelligence. What could a crafted description cause your generator to
  emit?
- **Failure modes.** Silent degradation, plausible-but-wrong test cases, API unavailability.
  Which of these does your pipeline currently detect, and which pass unnoticed?
- **Over-reliance.** What stops a reviewer treating generated tests as verified ones?
- **Placement justification.** Argue why generation is an acceptable role for the model and
  authoritative decision-making is not.

Map your findings to OWASP LLM Top 10 categories where they apply.

This phase is weighted heavily relative to its time. Reasoning is being assessed, not word count.

---

### Phase 6 — Document (0.5 hr)

A README that a hiring manager can read in three minutes and understand:

- What the pipeline does and why it exists.
- Architecture: a diagram or clear description of rule to test to build to deploy.
- How to run it.
- What you would build next and what you deliberately left out.

State any limitation honestly. An acknowledged gap costs nothing. A gap you conceal that a
reviewer finds costs a great deal.

---

### Stretch — Adversary validation (not assessed, no time allocated)

Execute Atomic Red Team tests matching your ATT&CK mappings against a lab endpoint shipping
telemetry to your workspace. Record which detections fired, which did not, and why. Publish the
coverage matrix.

This closes the loop from "the rule matches my synthetic event" to "the rule catches the real
technique." Attempt only after the core is complete.

---

## Submission

A public repository containing all of the above, plus a `SUBMISSION.md` stating:

- Total hours spent, honestly.
- Which phase overran and what you cut.
- Any AI assistance used beyond Phase 2, and for what.

Disclosed AI assistance is not penalised. Undisclosed assistance that is evident in the work is
treated as academic misconduct.

---

## Grading matrix

Total 100 marks. 50 to pass.

| # | Criterion | Weight | Fail (0-40%) | Pass (41-64%) | Credit (65-79%) | Distinction (80-100%) |
|---|---|---|---|---|---|---|
| 1 | **Detection quality** | 20 | Rules absent, copied, or logically broken | Three rules present, syntactically valid, plausible logic | All three shapes correctly distinct; ATT&CK mapping accurate; log source dependencies precise | FP sources named with operational specificity; tuning reasoning shows real environment awareness |
| 2 | **Test coverage** | 15 | No tests, or tests that do not exercise the rule | Positive and near-miss per rule; schema roughly correct | Near-misses are genuinely near; schema exact; tests would catch a real regression | Edge cases beyond the minimum; test design demonstrably shaped rule logic |
| 3 | **CI pipeline** | 20 | No pipeline, or it does not run | Runs; validates syntax; converts rules | Test step evaluates rules against cases and fails correctly; red build demonstrated | Clear failure reporting; pipeline structure a reviewer could extend without explanation |
| 4 | **Infrastructure as code** | 15 | Not deployed, or deployed by hand | Terraform provisions workspace and rules; applies successfully | Rule properties driven from Sigma metadata; state handling deliberate and explained; destroys cleanly | Parameterised for reuse across environments; no manual step anywhere in the path |
| 5 | **AI threat model** | 15 | Absent, or generic LLM risk boilerplate | Identifies trust boundary and names plausible risks | Prompt injection reasoning is specific to this pipeline; failure modes correctly separated into detected and undetected | Placement argument is genuinely persuasive; identifies a risk the brief did not prompt for |
| 6 | **Engineering discipline** | 10 | Secrets committed (automatic fail), or repository unusable | Sensible structure; meaningful commit history; no secrets | Commits scoped and messaged well; clean separation of concerns | Repository readable as a portfolio artefact without alteration |
| 7 | **Documentation and honesty** | 5 | Missing or misleading | README explains purpose and usage | Architecture clear; limitations stated | Reflection identifies what the author would do differently, with reasons |

### Automatic fail conditions

- Any credential, key, or token committed to the repository at any point in its history.
- Detection rules copied from a public rule set and presented as original.
- Undisclosed AI generation of material outside Phase 2.

### Grade bands

| Marks | Grade | Interpretation |
|---|---|---|
| 80-100 | Distinction | Would stand as portfolio evidence for a security engineering role |
| 65-79 | Credit | Solid working pipeline; one dimension underdeveloped |
| 50-64 | Pass | Core mechanics demonstrated; significant gaps in rigour |
| 0-49 | Fail | Pipeline incomplete or fundamentally unsound |

---

## Examiner's note on scope

Ten hours is deliberately tight. You are expected to run out of time somewhere. The assessed
skill is choosing *where*: a working three-rule pipeline with one thin phase beats six rules and
a pipeline that does not run.

If you must cut, cut rule count before you cut the test step. Criterion 3 carries the most
marks, and it is the only part of this project that most candidates for these roles cannot
already claim.
