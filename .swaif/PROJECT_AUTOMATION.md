# SWAIF Project Automation Mapping

RepoName: <REPLACE_WITH_THIS_REPO_NAME>

ProjectStatusFieldValues: <REPLACE_WITH_YOUR_PROJECT_STATUS_VALUES>

## Exact Status -> Label mapping

- Intake Ready -> (no stage label; ready for operator triage)
- Specify In Progress -> `swaif:specify`
- Plan In Progress -> `swaif:plan`
- Tasks In Progress -> `swaif:tasks`
- Implement In Progress -> `swaif:implement`
- Verify -> `swaif:verify`
- Done -> (no stage label; closeout state)
- Blocked -> `swaif:blocked` (optional)

## Operator loop

1. Move card in Project to a stage status.
2. Apply matching `swaif:*` label on the issue.
3. Workflow runs exactly one SWAIF stage.
4. Workflow updates/creates PR from `swaif/<feature-slug>` to `main`.
5. If failed, workflow adds `swaif:blocked` and comments next steps.
6. Operator fixes metadata/content and moves forward.

## SWAIF + Speckit stage sequence

```mermaid
sequenceDiagram
		autonumber
		participant U as User/Operator
		participant I as GitHub Issue
		participant W as SWAIF Factory Workflow
		participant S as scripts/swaif_stage.sh
		participant K as Speckit update-agent-context.sh
		participant G as Git branch swaif/<feature-slug>

		U->>I: Apply label swaif:specify
		I->>W: issues:labeled event
		W->>S: Run stage script (specify)
		S->>S: Bootstrap agent context files
		S->>G: Commit spec + agent context baseline
		W->>G: Push + create/update PR

		U->>I: Apply label swaif:plan
		I->>W: issues:labeled event
		W->>S: Run stage script (plan)
		S->>K: Run Speckit updater for agent context
		K->>G: Read plan/spec and evolve context file
		S->>G: Commit plan + context updates
		W->>G: Push + update PR

		U->>I: Apply label swaif:tasks / implement / verify
		I->>W: issues:labeled event (one per label)
		W->>S: Run stage script for current stage
		S->>K: Run Speckit updater again
		K->>G: Re-read repository and append context deltas
		S->>G: Commit stage output + context updates
		W->>G: Push + update PR

		Note over W,S: Each workflow run is stateless in runner memory
		Note over G: Persistent context lives in versioned files + commit history
```

## Context persistence rules

- The runner does not keep memory between workflow runs.
- Context continuity is guaranteed by committed files in the feature branch.
- The main persisted context files are:
	- `.github/agents/copilot-instructions.md`
	- `.specify/templates/agent-file-template.md`
	- `specs/<feature-slug>/spec.md`, `plan.md`, `tasks.md`
- Because each stage commits and pushes, the next label starts from the exact prior context snapshot.
