# Project Automation Mapping (Kanban drives SWAIF)

**Last updated:** 2026-02-15

## Columns (Status)
- Intake Ready
- Specify In Progress
- Spec Review
- Plan In Progress
- Plan Review
- Tasks In Progress
- Tasks Review
- Implement In Progress
- Verify
- Done
- Blocked

## Labels (triggers)
- swaif:specify
- swaif:plan
- swaif:tasks
- swaif:implement
- swaif:verify
- swaif:blocked

## Automation rules (GitHub Projects)
- Status -> Specify In Progress => add label swaif:specify
- Status -> Plan In Progress    => add label swaif:plan
- Status -> Tasks In Progress   => add label swaif:tasks
- Status -> Implement In Progress => add label swaif:implement
- Status -> Verify              => add label swaif:verify

## Operator loop
If blocked:
1) Read workflow logs + issue comments
2) Fix cause (edit artifact/code)
3) Re-apply stage label or move card back to stage column
