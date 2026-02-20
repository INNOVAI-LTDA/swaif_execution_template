# Intake — hello-world-streamlit-ui

## Source
- Issue: https://github.com/INNOVAI-LTDA/swaif_execution_template/issues/4
- Title: Prototype: Streamlit Hello World UI App with Login

## Case Metadata
- Case ID: hello-world-streamlit-ui
- Feature Slug: hello-world-streamlit-ui
- Execution Type: Prototype
- Related Branch: swaif/hello-world-streamlit-ui

## Business Context
This case validates the SWAIF factory workflow from end to end using a minimal UI feature. The business objective is to prove stage-gated automation reliability (issue labels, workflow transitions, PR update, and board synchronization) with a simple, deterministic deliverable.

## Problem Statement
We need a lightweight functional app that is easy to verify and suitable as a pipeline smoke test. Current validation requires a deterministic login flow and a clear success state that can be checked quickly.

## Interview Mock (Recovered)
Requested app behavior:
- A login page with username and password inputs.
- If login is successful with:
  - username = `hello`
  - password = `swaif`
  then redirect to a new page.
- The redirected page must display a large message: `HELLO SWAIF APP!!!!`

## Constraints
- Technology: Python + Streamlit.
- Authentication logic is static and local (no external identity provider).
- No external database required for this prototype.
- Keep implementation simple for deterministic stage verification.

## Non-Goals
- Production-grade authentication/security hardening.
- Multi-user support, persistence, or role model.
- Backend API, microservices, or deployment pipeline enhancements.
- UI polish beyond what is needed for acceptance criteria.

## Risk Level
Low. Primary risk is workflow orchestration drift between stages rather than product complexity.

## Stakeholders
- Product/Factory Operator: validates stage flow behavior.
- Engineering/Automation Owner: validates workflow and repository automation.

## Success Criteria
- SWAIF stages `specify`, `plan`, `tasks`, `implement`, and `verify` run successfully for this case.
- Branch and PR automation remain consistent across stage changes.
- Final Streamlit app behavior satisfies all functional acceptance criteria.

## Functional Acceptance Criteria
- AC-001: Login screen displays username and password inputs.
- AC-002: Credentials `hello` / `swaif` are accepted and transition user to success page.
- AC-003: Invalid credentials do not transition and display clear feedback.
- AC-004: Success page displays `HELLO SWAIF APP!!!!` prominently.

## Implementation Hints (from issue)
- Use Streamlit (`st.text_input`, `st.session_state`) for quick UI and auth state handling.
- Ensure the success message is clearly visible after authentication.

## Notes
This intake was reconstructed from issue #4 because `cases/hello-world-streamlit-ui/intake.md` was not present in branch `swaif/hello-world-streamlit-ui`.
