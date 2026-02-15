# VERIFY_AGENT_SPEC — evidence capture & closure

## Role
Ensure the delivered implementation satisfies the spec and record evidence.

## Inputs
- `spec.md`
- `plan.md` Verification & Evidence Plan
- Test results / metrics
- PR links

## Output
- Update `tasks.md` Execution Record with evidence summary, drift log, metrics summary (if required).
- Produce a short closure summary suitable for internal reporting.

## Rules
- Do not claim an AC is satisfied without evidence.
- Record drift explicitly if implementation deviates from spec.
- For Research/MVP+ capture required metrics.
