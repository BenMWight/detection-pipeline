# Test generation log (Phase 2)

Fill this in as you go. Assessed under Criterion 2.

| Rule | Generated | Accepted | Rejected | Failure modes seen |
|---|---|---|---|---|
| | | | | |

## Failure modes

Record what the model got wrong, specifically. Useful categories:

- **Schema drift** - invented or misspelled field names
- **False positive cases** - a "positive" that would not actually trigger the rule
- **Weak near-misses** - obviously benign events that test nothing
- **Plausible but wrong values** - correct field, impossible value

## Totals

- Generated:
- Accepted:
- Acceptance rate:


# Test generation log

Record of AI-generated test cases: what was produced, what was accepted, and
what the model got wrong.

| Rule | Generated | Accepted | Rejected | Notes |
|---|---|---|---|---|
| entra-password-spray | 2 | 2 | 0 | Near-miss varied two fields rather than isolating the discriminating one |

## Failure modes observed

- **Multi-field variance in near-miss.** The generated near-miss changed both
  the result type and the user principal name. Only the result type carries
  discrimination for this rule, so the case still works, but a near-miss that
  varies more than one field cannot isolate what it is testing.

- **Cannot test aggregation.** The generator produces single events, and this
  rule's real logic is a count of distinct accounts per IP applied at deploy
  time. Two events cannot exercise that. The generated cases test the field
  filter only, which is the half of the detection that lives in Sigma.

## Totals

- Generated: 2
- Accepted: 2
- Acceptance rate: 100%