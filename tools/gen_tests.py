import os, sys
from pathlib import Path
import anthropic

PROMPT = """Here is a Sigma detection rule:

{rule}

Generate two test events as JSON. The first must match this rule. The second
must be a near-miss: plausible benign activity that differs from the positive
case only in the field the rule discriminates on.

Field names must match the real Microsoft Sentinel table for this rule's
logsource (AuditLogs, SigninLogs, or AzureActivity).

Return only a JSON object with keys "positive" and "near_miss". No explanation,
no markdown fences."""

def main():
    rule_path = Path(sys.argv[1])
    rule = rule_path.read_text()

    client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    resp = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=2000,
        messages=[{"role": "user", "content": PROMPT.format(rule=rule)}],
    )

    print("".join(b.text for b in resp.content if b.type == "text"))

if __name__ == "__main__":
    main()