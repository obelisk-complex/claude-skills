# Agent-fleet learnings for the claude-agents guidance author

_Dated 2026-07-18. Written from the `claude-skills` branch that packaged 35 skills and built the fleet-audit loop._

This is a hand-off of the few lessons that branch learned which the `claude-agents` conventions do not already cover, each tied to the specific incident that produced it, plus an honest reverse section on where `claude-agents` is ahead. It is addressed to whoever writes or updates the "how to create or update an agent" guidance for `claude-agents`. Unqualified paths below (`REPORT_PROTOCOL.md`, `AGENT_CHECKLIST.md`, `agents/*.md`) are `claude-agents` files; `claude-skills` paths are prefixed. Every commit hash is labelled with its repository, because two of them collide across the two repos.

## Already covered, not repeated

Three of the five `claude-skills` lessons are already established practice in `claude-agents`. They are listed here only so the guidance author knows they were checked and need no new text.

- **Completion gates on a file, not a chat reply.** Fully covered: it is the whole of `REPORT_PROTOCOL.md` (skeleton before investigation, each finding appended with `Edit` as confirmed at lines 45-47, `## Completion` with `Status: COMPLETE` last at line 49, the zero-findings skeleton at lines 55-61 that makes an absent file mean "died" and an empty list mean "clean"), reinforced at `AGENT_CHECKLIST.md:60-66`.
- **One citable owner for a shared rule.** Substantially covered: `skill-auditor.md:22` and `skill-trigger-auditor.md:23` cross-defer so packaging and frontmatter rules "cannot drift apart", `REPORT_PROTOCOL.md:101-103` ships a pointer rather than a copy of the rule, and `agents/plan-audit-loop.md:44-45` states "This is the only statement of the rule." One honest wrinkle: `REPORT_PROTOCOL.md:116-120` admits its own gate script `check-report-protocol.sh` "is owned separately from this document" and needs reconciling, which is the drift the principle warns against, self-documented.
- **A gate that cannot fail is worthless.** Covered as applied practice: `fix-regression-checker.md` is a negative-control agent in all but name ("Presence alone is never a pass", line 34; a named "no-op family" at lines 39-52; "run the same counterfactual by hand ... A test that passes either way is checking nothing", line 123, with the `ctest -R` matching-nothing case worked through at line 50). `skill-trigger-auditor.md:112-118` builds should-not-fire adjacent cases and treats a run of CLEARED rows as the finding. `AGENT_CHECKLIST.md:68-74` mandates concrete self-verification.

## Gap A: verify an agent type is dispatchable, not that its file exists

This is the sharpest gap, and it is genuinely new. `claude-agents` has the adjacent *observation* but not the *gate*.

The observation is recorded in `claude-agents` commit `38f9aaf`, whose message notes: "Nothing here is installed to `~/.claude/agents/`, which has its own prior drift." A definition file in the repository is not the same object as a registered, dispatchable agent type in a live harness; this is exactly why a live agent-type listing can show different tools than the repo files claim.

`claude-skills` turned that observation into a hard lesson by exercising a loop for the first time. During the first end-to-end run of `fleet-audit-loop`, its own dispatchability check found that four of its seven roster agents were not registered agent types in the harness actually running the loop, only files in the companion repo (`claude-skills` commit `9fd7ee9`). The fix became a verification step, now at `claude-skills/src/fleet-audit-loop/SKILL.md:221-236`: confirm each roster agent is "dispatchable in the harness actually running this loop, not merely present as a file", check the harness's own agent-type listing before the round rather than after a dispatch fails, and record any substitution.

The gap in `claude-agents`: no such step exists. `agents/plan-audit-loop.md` dispatches `plan-auditor` and `requirements-auditor` in step 3 (line 53) with no precondition that either resolves to a registered type; its `## Verification` (lines 85-97) confirms only that each auditor wrote a `## Completion` block, which cannot fire for an agent that never dispatched. `AGENT_CHECKLIST.md` has no dispatchability item at all. A grep of both files for "dispatchable", "registered", "agent type", or "harness" returns nothing.

Recommendation: add one step to any agent that dispatches other agents (orchestrators, and loop agents like `plan-audit-loop`): before relying on a named agent type, confirm it is registered and dispatchable in the running harness, not merely that its `.md` exists; on a miss, substitute the nearest available type and record the substitution. This is `AGENT_CHECKLIST.md`'s self-verification discipline extended from "the definition is well-formed" to "the definition is callable here".

## Gap B: the negative-control principle has no single owner

`claude-agents` applies the negative-control principle well and in at least three places, but has no single artefact to cite for it, which puts it mildly at odds with the repo's own single-owner rule (Gap covered above, which it otherwise honours).

The applications: `fix-regression-checker.md` (presence is not effect, the no-op family, the by-hand counterfactual, lines 34, 39-52, 123); `skill-trigger-auditor.md:112-118` (adjacent should-not-fire cases, where a CLEARED run is itself the result); and `agents/plan-audit-loop.md:39` ("A zero tally from an auditor that never reported is not a zero tally"). Three agents encode the same idea in three vocabularies with no common reference.

`claude-skills` packaged it as one skill, `claude-skills/src/negative-controls/SKILL.md`: a control earns trust only once you have watched it fail, with the five-step falsify-restore-observe practice and the unfalsifiable-control failure mode stated once.

The evidence that the principle deserves a single owner is that `claude-agents` has independently removed two of its own inert controls, each a fresh rediscovery of the same lesson:

- `claude-agents` commit `8f2d0b3` stripped a "## Self-Checking Harness (mandatory)" block from four base auditors. It had been copied from an unrelated framework and instructed use of a "patch tool", "web_extract", and "browser", none of which exist in the fleet, and its JSON verdict return format was, in the commit's own words, "consumed by nothing".
- `claude-agents` commit `a6c796e` removed a "## Completion verdict (required)" block from `video-script-copywriter` whose `AGENT_VERDICT` line claimed to be "machine-read by the completion-gate hook" when, per the commit, "no such hook exists anywhere in the fleet".

Both are the same defect the negative-control skill names: a control wired to nothing, whose green signal was never distinguishable from its red one. Two independent removals in one repository is the signal that the authors keep re-deriving the rule and have nowhere to point.

Recommendation: give the principle one owner in `claude-agents` (a short section in `AGENT_CHECKLIST.md`, or a standalone note the three agents defer to), phrased as "a control earns trust only once you have watched it fail; a self-check whose tools or consumers do not exist is inert from its first step", and have `fix-regression-checker`, `skill-trigger-auditor`, and `plan-audit-loop` cite it rather than restate it.

## Gap C: the rationed-listing standard is not turned inward on agent descriptions

`claude-agents` already understands the economics of the dispatch listing, but applies it only to the skills it audits, not to its own agent definitions' triggers.

Applied outward: `skill-trigger-auditor.md:80-88` documents "The listing budget", that skill descriptions share roughly 1% of the context window and that on overflow the least-invoked descriptions are dropped first; `token-usage-auditor.md:84-88` prices a `description` as "loaded every session" and competing "for a fixed listing budget".

Not turned inward: `AGENT_CHECKLIST.md:9` holds an agent's own `description` only to "1-2 sentences explaining when to use the agent". Agents compete in a dispatch listing under the same rationing as skills, but the rationed-slot bar the fleet already knows is never stated for agent descriptions. This is a partial gap: the standard exists, it is simply not pointed at the fleet's own triggers.

Recommendation: extend the `AGENT_CHECKLIST.md:9` item so an agent `description` is held to the same bar the fleet applies to skills: concrete trigger situations in a caller's vocabulary, specific and concise enough to hold a rationed listing slot, not generic praise of the agent. `claude-skills/SKILL_CHECKLIST.md:46-73` is the worked form of that bar if a model is wanted.

## What claude-skills could learn from claude-agents

The debt runs both ways. On four points `claude-agents` is ahead of `claude-skills`' own skill conventions.

- **The capability-keyed report protocol is more rigorous than anything in `claude-skills`.** `REPORT_PROTOCOL.md:63-98` keys mandatory-versus-advisory on the agent actually holding `Write` plus `Edit`, and on parallel-dispatch or a named report path, rather than on run length. `claude-skills` skills carry no equivalent durable-findings discipline; the guidance author should know their model is the stronger one.
- **The enforcement model is layered and honestly bounded, with dated tests.** `AGENT_CHECKLIST.md:11-25` states that `permissionMode: plan` is a declaration not an enforcement boundary, that `disallowedTools: Write, Edit` is the real block, that a `Bash` grant is a residual write channel, and that the OS sandbox is session-wide and fails open without `socat`, concluding "The real integrity boundary is the merge" (`claude-agents` commits `f7b90bf` and `6dad92d`, the latter recording the 2026-07-18 test). `claude-skills` has no comparable explicit statement of where its own integrity boundary sits.
- **Model-tier reasoning is codified.** `docs/model-tiers.tsv` pins every agent's tier, and `README.md:160-170` gives the criteria plus the warning not to demote an agent whose checklist items are themselves absence-detection. `claude-skills` has only a partial analogue in the `research` skill's model-cost policy.
- **Turn the negative-control lens on their own definitions.** The two removals behind Gap B were self-audits of `claude-agents`' own files. `claude-skills` should do the same to its skills: grep for self-verification steps that name a command, tool, or hook that does not exist, which is precisely the failure `8f2d0b3` and `a6c796e` caught.
