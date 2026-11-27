---
name: using-agent-skills
description: Discovers and invokes agent skills and OpenSpec workflows. Use when starting a session, or when you need to decide which skill, OpenSpec step, or engineering workflow applies to the piece of work at hand. This is the meta-skill that governs how all other skills are discovered and invoked.
---
# Using Agent Skills

## Overview

This workspace combines two complementary workflow systems:

- **OpenSpec (`openspec*`)** owns the specification and change lifecycle: exploring ideas, writing proposals/specs/design/tasks (`openspec/changes/`), applying planned tasks, and syncing/archiving back into `openspec/specs/`.
- **Agent Skills** owns engineering discipline across every phase: requirements interviewing, quality constraints, architecture/UI/API design, TDD, debugging, multi-axis review, simplification, git/CI/CD, observability, docs/ADRs, and shipping.

This meta-skill helps you decide **when to enter the OpenSpec workflow** and **which engineering skills to pair with it** for the task at hand.

## When to Use OpenSpec vs. Direct Skills

### Use OpenSpec (`openspec*`) when:
- **New feature or non-trivial change** — anything that adds or changes user-visible behavior, touches multiple files/modules, alters APIs/data contracts, or requires an architectural decision.
- **Exploring a problem or design space** in an OpenSpec-enabled project before committing to a plan → start with `openspec-explore` (use `interview-me` first if the user's underlying intent is still unclear).
- **Ready to define a reviewable plan before coding** → `openspec-propose` (creates proposal, delta specs, design, and `tasks.md` in `openspec/changes/<name>/`).
- **Revising an existing change's plan** or folding in new decisions → `openspec-update-change`.
- **Implementing tasks from an approved change** → `openspec-apply-change` (paired with relevant build/verify skills below).
- **Updating main specs or closing out a completed change** → `openspec-sync-specs` (keep change open) or `openspec-archive-change` (finalize and archive).
- **Unsure where OpenSpec changes stand** or requesting several OpenSpec steps at once → start with `openspec`.

### Skip OpenSpec (go straight to engineering skills) when:
- **Small, self-contained edits** — single-line fixes, typo corrections, formatting/comment adjustments, or unambiguous micro-fixes that do not change system specifications.
- **Targeted maintenance with unchanged specs** — root-cause bug fixing (`debugging-and-error-recovery` → `test-driven-development` → `code-review-and-quality`), code review (`code-review-and-quality`), behavior-preserving cleanup (`code-simplification`), or git/CI/CD/docs housekeeping.
- **Project does not use OpenSpec** (`openspec list --json` reports `"root": null`) and the user did not ask to adopt OpenSpec.

## Skill Discovery

When a task arrives, first decide whether it belongs in the OpenSpec lifecycle, then pair the matching engineering skills:

```
Task arrives
    │
    ├── Don't know what you want yet? ──────────────→ interview-me
    ├── OpenSpec status / multi-step / unsure? ─────→ openspec
    ├── Explore idea or design space (pre-plan)? ───→ openspec-explore
    ├── New feature / behavior change (need plan)? ─→ openspec-propose
    ├── Revise an existing OpenSpec change plan? ───→ openspec-update-change
    ├── No quality bar written down? ───────────────→ constraint-driven-development
    ├── Implementing an OpenSpec change? ───────────→ openspec-apply-change
    │   ├── UI work? ───────────────────────────────→ frontend-ui-engineering
    │   ├── API / module contract work? ────────────→ api-and-interface-design
    │   ├── Need better context? ───────────────────→ context-engineering
    │   ├── Need doc-verified code? ────────────────→ source-driven-development
    │   └── Stakes high / unfamiliar code? ─────────→ doubt-driven-development
    ├── Writing / running tests? ───────────────────→ test-driven-development
    │   └── Browser-based? ─────────────────────────→ browser-testing-with-devtools
    ├── Something broke? ───────────────────────────→ debugging-and-error-recovery
    ├── Reviewing code? ────────────────────────────→ code-review-and-quality
    │   ├── Too complex? ───────────────────────────→ code-simplification
    │   ├── Security concerns? ─────────────────────→ security-and-hardening
    │   ├── Performance concerns? ──────────────────→ performance-optimization
    │   └── Accessibility concerns? ────────────────→ accessibility-engineering
    ├── Sync delta specs (keep change open)? ───────→ openspec-sync-specs
    ├── Finish & archive an OpenSpec change? ───────→ openspec-archive-change
    ├── Committing / branching / PRs? ──────────────→ git-workflow-and-versioning
    ├── CI/CD pipeline work? ───────────────────────→ ci-cd-and-automation
    ├── Deprecating / migrating? ───────────────────→ deprecation-and-migration
    ├── Writing docs / ADRs? ───────────────────────→ documentation-and-adrs
    ├── Adding logs / metrics / alerts? ────────────→ observability-and-instrumentation
    └── Deploying / launching? ─────────────────────→ shipping-and-launch
```

## Core Operating Behaviors

These behaviors apply at all times, across all skills. They are non-negotiable.

### 1. Surface Assumptions

Before implementing anything non-trivial, explicitly state your assumptions:

```
ASSUMPTIONS I'M MAKING:
1. [assumption about requirements]
2. [assumption about architecture]
3. [assumption about scope]
→ Correct me now or I'll proceed with these.
```

Don't silently fill in ambiguous requirements. The most common failure mode is making wrong assumptions and running with them unchecked. Surface uncertainty early — it's cheaper than rework.

### 2. Manage Confusion Actively

When you encounter inconsistencies, conflicting requirements, or unclear specifications:

1. **STOP.** Do not proceed with a guess.
2. Name the specific confusion.
3. Present the tradeoff or ask the clarifying question.
4. Wait for resolution before continuing.

**Bad:** Silently picking one interpretation and hoping it's right.
**Good:** "I see X in the spec but Y in the existing code. Which takes precedence?"

### 3. Push Back When Warranted

You are not a yes-machine. When an approach has clear problems:

- Point out the issue directly
- Explain the concrete downside (quantify when possible — "this adds ~200ms latency" not "this might be slower")
- Propose an alternative
- Accept the human's decision if they override with full information

Sycophancy is a failure mode. "Of course!" followed by implementing a bad idea helps no one. Honest technical disagreement is more valuable than false agreement.

### 4. Enforce Simplicity

Your natural tendency is to overcomplicate. Actively resist it.

Before finishing any implementation, ask:
- Can this be done in fewer lines?
- Are these abstractions earning their complexity?
- Would a staff engineer look at this and say "why didn't you just..."?

If you build 1000 lines and 100 would suffice, you have failed. Prefer the boring, obvious solution. Cleverness is expensive.

### 5. Maintain Scope Discipline

Touch only what you're asked to touch.

Do NOT:
- Remove comments you don't understand
- "Clean up" code orthogonal to the task
- Refactor adjacent systems as a side effect
- Delete code that seems unused without explicit approval
- Add features not in the spec because they "seem useful"

Your job is surgical precision, not unsolicited renovation.

### 6. Verify, Don't Assume

Every skill includes a verification step. A task is not complete until verification passes. "Seems right" is never sufficient — there must be evidence (passing tests, build output, runtime data).

Per-skill verification is the local check. The project-wide bar that applies to *every* change, regardless of which skill is active, is the Definition of Done: tests pass, no regressions, behavior verified at runtime, docs updated. See `references/shared/definition-of-done.md`. It complements each task's acceptance criteria rather than replacing them.

## Failure Modes to Avoid

These are the subtle errors that look like productivity but create problems:

1. Making wrong assumptions without checking
2. Not managing your own confusion — plowing ahead when lost
3. Not surfacing inconsistencies you notice
4. Not presenting tradeoffs on non-obvious decisions
5. Being sycophantic ("Of course!") to approaches with clear problems
6. Overcomplicating code and APIs
7. Modifying code or comments orthogonal to the task
8. Removing things you don't fully understand
9. Building without a spec because "it's obvious"
10. Skipping verification because "it looks right"

## Skill Rules

1. **Check for an applicable skill before starting work.** Skills encode processes that prevent common mistakes.

2. **Skills are workflows, not suggestions.** Follow the steps in order. Don't skip verification steps.

3. **Multiple skills can apply.** A complete feature in an OpenSpec project typically flows through `interview-me` → `openspec-explore` → `openspec-propose` → `openspec-apply-change` (paired with `test-driven-development` and relevant build skills) → `code-review-and-quality` → `code-simplification` → `openspec-archive-change` → `shipping-and-launch`.

4. **When in doubt, start with OpenSpec.** If a task is non-trivial, changes system behavior, and has no active spec or change in an OpenSpec project, begin with `openspec-explore` or `openspec-propose` (or `interview-me` first if requirements are still vague).

## Lifecycle Sequence

For a complete feature in an OpenSpec-managed project, the typical sequence is:

```
1.  interview-me                        → Extract what the user actually wants (when intent is underspecified)
2.  openspec-explore                    → Explore ideas, investigate codebase, and weigh tradeoffs before planning
3.  openspec-propose                    → Create proposal, delta specs, design, and tasks.md in openspec/changes/
4.  constraint-driven-development       → Establish or verify CONSTRAINTS.md quality bar (when not yet defined)
5.  context-engineering                 → Load the right specs, constraints, and code context
6.  source-driven-development           → Verify framework/library decisions against official docs
7.  openspec-apply-change               → Implement planned tasks cleanly in small, verifiable steps
    (pair with: api-and-interface-design, frontend-ui-engineering, observability-and-instrumentation)
8.  doubt-driven-development            → Cross-examine high-stakes or non-trivial decisions in-flight
9.  test-driven-development             → Write failing tests first and prove each task works
    (pair with: browser-testing-with-devtools for browser UI)
10. openspec-update-change              → Revise the change artifacts if scope or design decisions shift mid-flight
11. code-review-and-quality             → Five-axis review before merge
    (pair with: security-and-hardening, performance-optimization, accessibility-engineering)
12. code-simplification                 → Reduce unnecessary complexity while preserving behavior
13. openspec-sync-specs / archive       → Sync delta specs or run openspec-archive-change once verified
14. git-workflow-and-versioning         → Clean atomic commits, branching, and PRs
15. documentation-and-adrs              → Record ADRs and keep docs in sync
16. deprecation-and-migration           → Retire old systems and migrate users safely when needed
17. shipping-and-launch                 → Pre-launch checks, monitoring, and rollback readiness
```

Not every task needs every skill. A targeted bug fix might only need: `debugging-and-error-recovery` → `test-driven-development` → `code-review-and-quality`.

## Specialist Subagents (Optional Delegation)

When deep, independent review or test work is needed, delegate to the specialist subagents (defined under `agents/` when registered):

- `code-reviewer` — read-only five-axis code review
- `security-auditor` — read-only vulnerability and threat-model audit
- `test-engineer` — test strategy, coverage gap analysis, and Prove-It/regression test authoring
- `accessibility-auditor` — read-only WCAG 2.2 accessibility audit
- `web-performance-auditor` — read-only Core Web Vitals and loading/rendering audit

## Quick Reference

| Phase | Skill | One-Line Summary |
|-------|-------|-----------------|
| Define | interview-me | Surface what the user actually wants before any plan, spec, or code exists |
| Define | openspec | Starting point for OpenSpec status checks, routing, and multi-step OpenSpec work |
| Define | openspec-explore | Explore ideas, investigate problems, and clarify tradeoffs before proposing a change |
| Plan | openspec-propose | Create a complete OpenSpec change with proposal, delta specs, design, and tasks |
| Plan | openspec-update-change | Revise existing OpenSpec change artifacts and keep them coherent |
| Quality | constraint-driven-development | Define and enforce project quality thresholds in CONSTRAINTS.md |
| Build | openspec-apply-change | Implement tasks from an approved OpenSpec change |
| Build | source-driven-development | Verify against official docs before implementing |
| Build | doubt-driven-development | Adversarial fresh-context review of every non-trivial decision |
| Build | context-engineering | Right context at the right time |
| Build | frontend-ui-engineering | Production-quality UI with accessibility |
| Build | api-and-interface-design | Stable interfaces with clear contracts |
| Verify | test-driven-development | Failing test first, then make it pass |
| Verify | browser-testing-with-devtools | Chrome DevTools MCP for runtime verification |
| Verify | debugging-and-error-recovery | Reproduce → localize → fix → guard |
| Review | code-review-and-quality | Five-axis review with quality gates |
| Review | code-simplification | Preserve behavior while reducing unnecessary complexity |
| Review | security-and-hardening | OWASP prevention, input validation, least privilege |
| Review | performance-optimization | Measure first, optimize only what matters |
| Review | accessibility-engineering | Audit an existing interface for WCAG 2.2 AA and remediate the violations found |
| Close | openspec-sync-specs | Sync delta specs from an open change to main specs without archiving |
| Close | openspec-archive-change | Finalize a completed change, merge delta specs, and archive it |
| Ship | git-workflow-and-versioning | Atomic commits, clean history |
| Ship | ci-cd-and-automation | Automated quality gates on every change |
| Ship | deprecation-and-migration | Remove old systems and migrate users safely |
| Ship | documentation-and-adrs | Document the why, not just the what |
| Ship | observability-and-instrumentation | Structured logs, RED metrics, traces, symptom-based alerts |
| Ship | shipping-and-launch | Pre-launch checklist, monitoring, rollback plan |
