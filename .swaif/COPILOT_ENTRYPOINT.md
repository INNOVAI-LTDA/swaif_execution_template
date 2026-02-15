# Copilot Entrypoint — SWAIF Factory Execution

Use this file as the first reference in GitHub Copilot Chat.

## Engine Snapshot (pinned)
- .swaif/engine/agents/
- .swaif/engine/templates/
- .swaif/engine/.specify/

## Canonical Agents
Follow these files exactly:
- .swaif/engine/agents/FIP_AGENT_SPEC.md
- .swaif/engine/agents/SPEC_AGENT_SPEC.md
- .swaif/engine/agents/PLAN_AGENT_SPEC.md
- .swaif/engine/agents/TASKS_AGENT_SPEC.md
- .swaif/engine/agents/IMPLEMENT_AGENT_SPEC.md
- .swaif/engine/agents/VERIFY_AGENT_SPEC.md

## Templates
- .swaif/engine/templates/FIP_TEMPLATE.md
- .swaif/engine/templates/spec-template.md
- .swaif/engine/templates/plan-template.md
- .swaif/engine/templates/tasks-template.md
- .swaif/engine/templates/constitution-template.md

## Recommended prompts
- “Act as the FIP Agent. Validate sufficiency for the declared execution type and output a FIP that matches the template.”
- “Act as the Spec/Plan/Tasks Agent. Use the template and do not invent missing info.”
