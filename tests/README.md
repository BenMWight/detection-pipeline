# Test cases

One directory per rule, named to match the rule file stem.

```
tests/
  rule-name/
    positive.json     must trigger the rule
    near-miss.json    must NOT trigger it
```

Events must match your log source's real schema. A test against an invented
schema proves nothing.

The near-miss is the part that matters. If it is obviously benign, it is not
testing anything. It should be close enough that a careless rule would fire
on it.
