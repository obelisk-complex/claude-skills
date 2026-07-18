# Skills: Packaging Repair, Checklist, and the Fleet Audit Loop

> **For agentic workers:** REQUIRED SUB-SKILL: use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Each task is written to be executable by someone who sees that task and the Global Constraints and nothing else.

**Date:** 2026-07-18
**Repository:** `/media/owner/Workspace/claude-skills`
**Companion plan:** `/media/owner/Workspace/claude-agents/docs/plans/2026-07-18-agent-report-protocol-model-tiers-auditors.md` (agent-side work). Read the split rule below before assuming a task belongs here.

**Goal:** Make this repo's skills actually loadable, give them a structural contract to be audited against, and add one skill that runs the agent-auditor fleet as a rotating loop rather than a sweep somebody assembles by hand each time.

## Which repo owns what

Split by artefact type, not by subject matter:

- **`claude-skills/` owns every skill**, including skills whose *subject* is agents - `fleet-audit-loop` (Task 4) drives the agent-auditor fleet and lives here.
- **`claude-agents/` owns every `*.md` with agent frontmatter**, including agents whose *subject* is skills. `skill-auditor` and `skill-trigger-auditor` are therefore planned in the companion plan (its Task 7), not here, even though they audit this repo's contents. Task 2 below creates the checklist they audit against, so the two plans meet at that file.
- **The skeleton-report convention is owned by `claude-agents/REPORT_PROTOCOL.md`** (companion plan, Task 3). It governs agent runtime behaviour. Task 4 below references it by path. **Do not restate the rule here.** Two copies of one rule in two repositories is precisely the parallel-place defect these plans exist to prevent - it was the single most recurrent defect across eleven audit rounds.

## Repository facts (verified 2026-07-18; re-verify with the commands given before trusting them)

**Layout.** 29 skills, each existing twice: a README-style document at the repo root (`code-quality.md`, `fleet-qa-loop.md`, ...) with `## What it does` / `## Key ideas` / `## Installation` sections, and a packaged `skills/<name>.skill` file. A `.skill` is a **zip archive** containing `<name>/SKILL.md`, and that `SKILL.md` is the real skill: YAML frontmatter (`name`, `description`) followed by the instructional body. The root `.md` is documentation *about* the skill; the zipped `SKILL.md` is the skill. Confirm with `unzip -l skills/code-quality.skill` and `unzip -p skills/code-quality.skill code-quality/SKILL.md | head`.

There is **no build script**: no Makefile, no `*.sh`, nothing that regenerates a `.skill` from a source tree. The zips were produced by hand. `README.md` documents installation as "Download the `.skill` file and install it via Claude's skill management interface". Also present: `references/` (7 checklists) and `skills/` (the 29 zips). No `docs/` directory existed before this plan; this file creates `docs/plans/`.

**Relationship to `~/.claude/skills` (15 entries) - and the problem it exposes.** Mixed and mostly broken:

- 7 entries are **symlinks into this repo**: `3d-print-design.md`, `code-quality.md`, `cosmos-compose.md`, `frontend-design.md`, `github-actions.md`, `interview.md`, `pcb-engineer.md` (each `~/.claude/skills/<name>.md -> /media/owner/Workspace/claude-skills/<name>.md`). They point at the **root README documents, not the `SKILL.md` bodies.**
- 6 entries are **plain files or directories that exist nowhere in this repo**: `disposition-ledger.md`, `model-bakeoff.md`, `readme-conventions.md`, `research.md`, `wiki-first.md`, and `songwriting/`.
- 2 entries are plain-file copies of skills that *are* in the repo: `copywriting.md` (identical to the repo copy) and `svg-illustrator.md` (differs from it).
- Only **one** entry is packaged the way Claude Code requires: `songwriting/`, a directory containing `SKILL.md`.

**The load-bearing consequence.** Claude Code loads a user-scope skill from `~/.claude/skills/<name>/SKILL.md`. A bare `~/.claude/skills/<name>.md` is **not loaded**. The proof is in the session that produced this plan: of the 15 entries, only `songwriting` appeared in the available-skills list. `code-quality`, `frontend-design`, `interview`, `github-actions`, `pcb-engineer`, `cosmos-compose`, `3d-print-design`, `copywriting`, `svg-illustrator`, `disposition-ledger`, `model-bakeoff`, `readme-conventions`, `research`, and `wiki-first` did not. **Fourteen of the fifteen installed skills are inert.** They are on disk, they are symlinked, and nothing loads them.

So the repo-to-installed relationship is not "source and deployment" and not simply "drifted": the installation mechanism itself does not work, and separately, six skills exist only on disk and are at risk from any disk-side cleanup. Task 1 fixes both. Re-verify before starting:

```bash
ls -l ~/.claude/skills/
find ~/.claude/skills -name SKILL.md          # expect exactly one, under songwriting/
```

**Consequence for every task in this plan: "done" means the skill loads.** A skill that is correct in the repo and inert on disk has changed nothing. Every task ends with the `find` above showing the new skill's `SKILL.md`.

## Global Constraints

Every task below implicitly includes this section.

- **Prompt authoring is governed by `/media/owner/Workspace/HUMANE_PROMPTING.md`.** Read it before writing or editing any skill body. Its eleven principles are guidance; its ten-test torment-nexus checklist is a hard gate - any "yes" means revise. Its own guidance for skill files: strip persona openers and lead with domain framing; keep red-flag tables (factual reference, not threats); add abstention reward to verification gates; use SBI framing in review sections.
- **British English. No em-dashes.** Use `-`, commas, semicolons, colons, or parentheses.
- **A skill's content loads into the caller's context, not an isolated one.** Unlike an agent, a skill spends the tokens of the conversation that triggered it. Length is a direct cost to every user of the skill. This is why `token-usage-auditor` (companion plan, Task 1) matters more here than there.
- **Each skill exists in three places and all three move together:** the root `.md` documentation, `skills/<name>.skill`, and the installed `~/.claude/skills/<name>/SKILL.md`. Updating one and not the others is the parallel-place defect. Task 1 builds the script that makes this mechanical.
- **Do not delete anything from `~/.claude/skills`.** Six skills live only there and exist in no repository. Task 1 imports them; nothing in this plan removes files from that directory.

## Evidence behind this plan

Eleven audit rounds over one large plan, plus one orchestration session. Stated once; tasks reference by name.

1. **Audits sample, they do not exhaust.** Findings tracked wherever each round was pointed and did not decay with repetition; rounds aimed at new dimensions were still producing CRITICALs and HIGHs after eight rounds. A falling finding count from re-running the same sweep is not convergence - it is evidence the sweep has been exhausted, not the artefact.
2. **Class-level context transfers; instance-level context anchors.** Briefing an auditor with defect *patterns* produced findings in new locations; briefing it with the specific defects already found and fixed biased it toward confirming rather than checking.
3. **Disproved-candidate lists are the high-value half.** Carrying forward "investigated, not a defect, here is the proof" stopped re-litigation. One numerical convention was independently re-settled five times before this was adopted.
4. **A regression checker must verify intent, not text.** A fix was present and correct in form but useless - a `ctest` invocation exiting 0 when its regex matched nothing, so the gate passed having run no tests.
5. **Fixes survive later editing when anchored by inline justification** naming the failure mode with a file and line. Of 57 fixes, none had decayed; roughly three quarters carried an argument an editor would have to delete deliberately.
6. **Parallel-place omission is the most recurrent defect** - eleven occurrences across eleven rounds, including one by an agent explicitly briefed about that exact pattern. Briefing is not sufficient; gates are.
7. **Coherence degrades at the document edge.** Every defect a coherence audit found was in the most recently written material.
8. **Idle is not done.** Subagents went idle without sending a final report at least six times in one session; two lost work silently, because a follow-up message arrived after the agent had finished its pass and it idled without reading it.
9. **Do not dispatch against work that is merely idle.** Dispatching a second agent onto a file another agent still held caused a near-collision caught only by luck.

---

## Task 1: Make skills loadable, and import the orphans

**Effort:** ~3h expected; worst case ~4h if any of the six orphaned skills needs its documentation written from scratch.

**Why first:** every other task in this plan produces a skill. If the installation mechanism does not work, each of those tasks ships something inert, and the failure is silent - nothing reports that a skill did not load.

**Files:**
- `scripts/build-skills.sh` (new)
- `scripts/install-skills.sh` (new)
- `skills/*.skill` (29, rebuilt)
- Six new root `.md` documents plus their `.skill` packages, for the orphans
- `~/.claude/skills/**` (install target)
- `README.md` (Installation section, and the skills table)

**Interfaces:**

`scripts/build-skills.sh` regenerates every `skills/<name>.skill` from a source directory, replacing the hand-made zips. This needs a source of truth for `SKILL.md` that is currently only inside the zips. Extract first:

```bash
mkdir -p src
for z in skills/*.skill; do n=$(basename "$z" .skill); unzip -o -q "$z" -d src/; done
```

That gives `src/<name>/SKILL.md` for all 29. From then on `src/` is the source, `skills/*.skill` is a build artefact, and the root `.md` remains hand-written documentation. State that relationship in `README.md`, otherwise the next editor will change the zip and lose it on the next build.

`scripts/install-skills.sh` installs `src/<name>/` as `~/.claude/skills/<name>/` (directory with `SKILL.md`, plus any supporting files - `songwriting/` carries four), then verifies with `find ~/.claude/skills -name SKILL.md | wc -l` and exits 1 if the count is below the number installed. **It must remove the 14 inert flat `.md` files only after the corresponding directory install has been verified**, and must not touch anything it did not install.

**The six orphans** (`disposition-ledger`, `model-bakeoff`, `readme-conventions`, `research`, `wiki-first`, `songwriting`) exist only in `~/.claude/skills`. Copy each into `src/<name>/SKILL.md` and write a root `.md` for each matching the house documentation shape (`## What it does`, `## Key ideas`, `## Installation`). Two of them already have proper frontmatter (`disposition-ledger`, `model-bakeoff` - check the rest). `songwriting/` is already a directory with supporting files and copies across whole. Note that `songwriting` is personal to the user rather than general-purpose tooling; import it so it is backed up, and flag in your report whether it belongs in a public repo at all rather than deciding that yourself.

**Steps:**

- [ ] 1. Extract all 29 zips into `src/` as above. Diff each `src/<name>/SKILL.md` against the root `<name>.md` to confirm they are genuinely different artefacts and not one stale copy of the other. If any pair is identical, that skill has no separate documentation and should be reported, not silently duplicated.
- [ ] 2. Write `scripts/install-skills.sh` and run it in check-only mode (`--check`) before it copies anything. **Expected failure:** it reports that 34 skills (29 packaged plus 5 orphans, excluding the already-correct `songwriting`) have no `~/.claude/skills/<name>/SKILL.md`, and exits 1. Confirm `find ~/.claude/skills -name SKILL.md` returns exactly one path before you start - if it returns more, the situation has changed since 2026-07-18 and this task's premise needs rechecking.
- [ ] 3. Write `scripts/build-skills.sh`; rebuild all 29 zips from `src/` and confirm each rebuilt zip's `SKILL.md` is byte-identical to what was extracted (`unzip -p` and `cmp`). A build script that silently changes content is worse than the hand-made zips it replaces.
- [ ] 4. Import the six orphans into `src/` and write their root `.md` documents. Build their zips. Run `scripts/install-skills.sh` for real, then `--check`; expect exit 0 and `find ~/.claude/skills -name SKILL.md` to return 35.
- [ ] 5. Update `README.md`: the Installation section (source-of-truth relationship, `src/` to `skills/` to installed), and add the six imported skills to the skills table. Commit. In the commit body, record that 14 skills were inert before this change - it is the fact that justifies the `src/` restructure to anyone reading the history later.

---

## Task 2: `SKILL_CHECKLIST.md`

**Effort:** ~2h expected; worst case ~3h.

**Depends on:** Task 1 (the packaging rules it encodes are only knowable once `src/` exists). **Depended on by:** the companion plan's Task 7 (`skill-auditor` audits against this file).

**Files:**
- `SKILL_CHECKLIST.md` (new, repo root)
- `README.md` (one line pointing at it)

**Interfaces.** Mirror the shape of `/media/owner/Workspace/claude-agents/AGENT_CHECKLIST.md` - read it first; it is the house model for this kind of document, and its sections are Frontmatter / Memory loop / Scope boundary / Core workflow / Self-verification / Output format / Guiding principles / Humane prompting gate / Style rules. Keep the shape where it transfers; the content differs substantially because skills are not agents:

**Transfers directly:** the humane-prompting gate (identical wording, pointing at the same `HUMANE_PROMPTING.md`), the style rules (British English, single hyphens, single blank line between sections), and the self-verification requirement.

**Does not transfer:** the memory loop (skills have no memory), `tools` / `permissionMode` / `model` / `maxTurns` / `color` (skills have none of these), and `isolation: worktree`. A checklist that asks a skill for its `permissionMode` will produce a fleet of false findings.

**New, with no agent equivalent:**

- **Packaging.** `src/<name>/SKILL.md` exists; frontmatter carries `name` and `description`; the built zip contains `<name>/SKILL.md` at that path; the installed copy is a directory. **This is CRITICAL severity**, because a skill that does not load has no other properties worth auditing - and fourteen skills were in that state on 2026-07-18 with nothing reporting it.
- **Trigger quality.** The `description` field is the whole matching surface. It states the situations the skill applies to in the words a user would use, not the skill's internal vocabulary. Compare `disposition-ledger`'s description (names the specific agents whose output it handles, and the failure it prevents) against a bare "Use for tracking findings".
- **Context cost.** A skill's body loads into the caller's context. The checklist asks for a stated length budget and flags anything that reads as reference material a caller will not need on every invocation - that material belongs in `references/`, which this repo already has for exactly this purpose.
- **Overlap.** The skill states its boundary against its nearest sibling. `disposition-ledger` does this well and is the worked example to cite: it distinguishes itself from `superpowers:receiving-code-review` in a paragraph, saying which governs what.

**Steps:**

- [ ] 1. Read `/media/owner/Workspace/claude-agents/AGENT_CHECKLIST.md` in full, then three skills of different character: `src/code-quality/SKILL.md` (long, foundational), `src/fleet-qa-loop/SKILL.md` (procedural, loop-shaped), `src/disposition-ledger/SKILL.md` (short, gate-shaped). Derive the checklist from what the good ones do, not from the agent checklist's structure - the structure is the model, the content is not.
- [ ] 2. Write `scripts/check-skills.sh` asserting the mechanical items: every `src/*/SKILL.md` exists, has frontmatter with `name` and `description`, `name` matches its directory, and a corresponding `skills/<name>.skill` exists whose contents include `<name>/SKILL.md`. Run it. **Expected result:** it exits 0 if Task 1 landed cleanly. If it exits 1, Task 1 is incomplete - fix that before continuing, because this task's checklist assumes it. If Task 1 has not run at all, expect it to fail on the missing `src/` directory.
- [ ] 3. Write `SKILL_CHECKLIST.md`. For each item that can be mechanically checked, say which script checks it and note that the script is the gate; for each that cannot, say plainly that it needs a reader. Do not write a checkbox implying a check exists when none does - a gate that cannot fail is read as coverage and is worse than no gate (evidence item 4).
- [ ] 4. Apply the checklist by hand to three skills not read in step 1, one of them `svg-illustrator` (33k, the largest in the repo, and the most likely to fail the context-cost item). If it produces no findings on that one, the context-cost criteria are not discriminating.
- [ ] 5. Add the pointer line to `README.md`. Commit.

---

## Task 3: Extend `disposition-ledger` with cross-round carry-forward

**Effort:** ~1h expected; worst case ~1.5h.

**Depends on:** Task 1 (the skill must be in `src/` before it can be edited here).

**Why extend rather than build new (evidence item 3).** Carrying forward "these were investigated, are not defects, here is the proof" is the high-value half of an audit loop - one numerical convention was independently re-settled five times before this was adopted. The obvious move is a new "disproved-candidate ledger" skill. That would be a mistake: `disposition-ledger` already defines a file-backed ledger whose `rejected` disposition requires "the specific code, test, or fact that makes the finding wrong", which is a disproved-candidate entry under a different name. A second skill would duplicate a table format, an ID convention, and a gate across two artefacts that must then be kept in step. **Extend the one that exists.**

**Files:**
- `src/disposition-ledger/SKILL.md`
- `disposition-ledger.md` (the root documentation created in Task 1)
- `skills/disposition-ledger.skill` (rebuilt)

**Interfaces.** What the skill currently has: a gate ("no blocker or major finding ships without a disposition"), four terminal states (`accepted` / `rejected` / `deferred` / `blocked`), and a Markdown table with columns ID, Source, Severity, Finding, Disposition, Evidence/Link, Approved by.

What to add - one section, roughly 200 words:

- **Rejected rows carry forward between rounds.** When a multi-round audit starts a new round, the ledger's `rejected` rows go into the next round's brief as a settled list with their evidence. The purpose is to stop the same non-defect being re-investigated; it is not permission to skip checking whether the *reasoning* still holds if the artefact changed underneath it. State the distinction: a `rejected` row whose evidence cites a file that has since been edited is reopened, not carried.
- **Carry the row's evidence, not just its conclusion.** "We looked at this, it is fine" invites re-litigation; "this is not a defect because `<file:line>` does `<X>`" ends it. This is the same mechanism as evidence item 5 - a claim carrying an argument survives, a bare assertion gets re-opened by the next reader.
- **This is the one place instance-level detail belongs in a brief.** Everywhere else, briefing an auditor with specific prior findings biases it toward confirming them rather than checking (evidence item 2). The disproved list is the deliberate exception, because its purpose is to remove ground from the search rather than to direct the search. Say so explicitly, because the two rules look contradictory side by side and an editor who sees only one will "fix" it.

**Steps:**

- [ ] 1. Read `src/disposition-ledger/SKILL.md` in full. It is roughly 100 lines and its argument is tight; the new section must fit its voice rather than sit beside it as an appendix.
- [ ] 2. `grep -n 'carry\|round\|next round' src/disposition-ledger/SKILL.md`. **Expected result:** no match, or matches unrelated to cross-round carry-forward - confirming the concept is genuinely absent. If it is already covered, stop and report; the extension is unnecessary and this task should close as a no-op rather than adding a second statement of the same rule.
- [ ] 3. Write the section. Place it after the "Ledger format" section, so it is adjacent to the table it operates on rather than at the document's end (P4a serial position: the end is where the reader looks for the output template, not for a rule about round two).
- [ ] 4. Rebuild the zip with `scripts/build-skills.sh`, reinstall with `scripts/install-skills.sh`, confirm `~/.claude/skills/disposition-ledger/SKILL.md` contains the new section.
- [ ] 5. Update the root `disposition-ledger.md` documentation's `## Key ideas` with one line for the addition. Commit.

---

## Task 4: `fleet-audit-loop` skill

**Effort:** ~4h expected; worst case ~6h. The longest task here, and the one carrying the most of the audit-loop evidence.

**Depends on:** Task 1 (packaging), the companion plan's Task 1 (`token-usage-auditor` exists), Task 3 there (`REPORT_PROTOCOL.md` exists), and Task 6 there (`fix-regression-checker` exists). It can be *written* before those land, but its dimension roster and its references will name agents that do not exist yet, so verify each name resolves before calling it done.

**Files:**
- `src/fleet-audit-loop/SKILL.md` (new)
- `fleet-audit-loop.md` (new, root documentation)
- `skills/fleet-audit-loop.skill` (built)
- `README.md` (skills table row)

**Model it on `fleet-qa-loop`, which already exists and solves the adjacent problem.** Read `src/fleet-qa-loop/SKILL.md` first. It runs mechanical linters, then the QA subagent fleet, looping until clean, and it already carries several of the ideas below - append-as-you-go reporting, adversarial verification of findings before fixing, termination on CLEAN or STALLED. `fleet-audit-loop` is its sibling for a different target: **agent and skill definitions rather than code.** Say so in the scope boundary. Where `fleet-qa-loop` already states an idea well, reference it rather than restating it.

**What this skill must encode that `fleet-qa-loop` does not:**

**Rotate dimensions; do not re-run the sweep (evidence item 1).** Findings tracked wherever each round was pointed and did not decay with repetition; rounds aimed at new dimensions were still producing CRITICALs and HIGHs after eight rounds. So the loop's round counter selects a *dimension*, not a repetition. A falling finding count across rounds that reuse a dimension means the sweep is exhausted, not the artefact - and reading it as convergence is the specific error this skill exists to prevent. The roster:

| Round | Dimension | Agent |
|---|---|---|
| 1 | Structural conformance to the checklist | `agent-auditor` / `skill-auditor` |
| 2 | Domain coverage gaps | `blind-spot-auditor` |
| 3 | Context and token waste | `token-usage-auditor` |
| 4 | Trigger and activation (skills only) | `skill-trigger-auditor` |
| 5 | Internal coherence, weighted to the newest material | `conformance-auditor` |
| 6 | Fixes from rounds 1-5 still achieve their intent | `fix-regression-checker` |

Termination is on **dimensions exhausted**, not on a clean round. A clean round in one dimension says nothing about the next. State the honest limit too: six dimensions is what this fleet currently has, and running out of dimensions is not proof the artefact is clean, only that this fleet has nothing further to point at it.

**Brief with classes, not instances (evidence item 2).** Each round's brief carries recurring defect *patterns* from prior rounds, never the specific defects already found and fixed. Pattern briefing produced findings in new locations; instance briefing produced confirmation of the instances. One auditor described the mechanism: knowledge recalled from its own memory arrives as "here is what was true, verify it", which invites checking, whereas the same content in a brief arrives as instruction. Round 6 is the deliberate exception - `fix-regression-checker` holds the instance list, because confirming a known list is its job.

**Carry the disproved list forward.** Between rounds, the `rejected` rows from the `disposition-ledger` (see Task 3) go into the next brief with their evidence. Reference the skill; do not define a second ledger format here.

**Verify on disk; do not read idle as done (evidence item 8).** After dispatching a round, confirm each agent's report file exists and its `## Completion` block is written, per `/media/owner/Workspace/claude-agents/REPORT_PROTOCOL.md`. An agent that has gone quiet with `Status: IN PROGRESS` died mid-pass; an agent that has gone quiet with no file never started. Neither is done, and neither reports itself. In one session subagents went idle without sending a final report at least six times, and twice work was silently not done at all - a follow-up message arrived after the agent had finished its pass and it idled without ever reading it, so the instructions were lost with no signal. The orchestrator found out by inspecting the working tree. **The report file is what the loop reads. Re-prompting is the fallback, not the mechanism.**

**Do not dispatch against work that is merely idle (evidence item 9).** Before dispatching a round, confirm no agent from the previous round still holds a file in the target set. Dispatching a second agent onto a file another was still holding caused a near-collision caught only by luck. The check is the previous round's report files: every one shows `Status: COMPLETE`, or the round is not finished regardless of how quiet it has gone.

**Prefer gates to prose where an invariant can fail (evidence item 6).** Parallel-place omission was the single most recurrent defect - eleven occurrences across eleven rounds, including one in work by an agent explicitly briefed about that exact pattern. Briefing did not prevent it. So where a round's finding can be expressed as a check that fails, the loop's fix step writes the check as well as the fix, under `scripts/`. State the limit honestly: not every instance is mechanisable - of the eleven, one was a briefing error and one was domain knowledge, neither expressible as a script - and a check that cannot fail is worse than none, because it is read as coverage. When an invariant cannot be mechanised, the loop records it as a prose rule sited at the point of use rather than in a distant document, and says which it chose.

**Weight scrutiny to the newest material (evidence item 7).** Round 5's brief says so explicitly: a coherence audit found every one of its defects in the most recently written material, because each new section was written against a snapshot its predecessors had since modified.

**Steps:**

- [ ] 1. Read `src/fleet-qa-loop/SKILL.md` in full and `/media/owner/Workspace/claude-agents/agents/plan-audit-loop.md`. The latter is a near neighbour already in the fleet - an agent, not a skill, that loops `plan-auditor` plus `requirements-auditor` over a plan. Decide and state in your report whether `fleet-audit-loop` supersedes it, wraps it, or sits beside it targeting definitions rather than plans. Do not leave two overlapping loops with no stated boundary; that is the overlap failure `SKILL_CHECKLIST.md` (Task 2) exists to catch, and shipping it in the same week would be poor form.
- [ ] 2. Verify every agent name in the dimension roster resolves: `ls /media/owner/Workspace/claude-agents/agents/{agent-auditor,blind-spot-auditor,token-usage-auditor,skill-auditor,skill-trigger-auditor,conformance-auditor,fix-regression-checker}.md`. **Expected failure at time of writing:** `token-usage-auditor`, `skill-auditor`, `skill-trigger-auditor`, and `fix-regression-checker` do not exist - they are the companion plan's Tasks 1, 7, and 6. Either wait for those, or write the roster with the missing names marked and re-run this check before step 5. A skill that dispatches an agent which does not exist fails at run time with nothing to indicate why.
- [ ] 3. Write `src/fleet-audit-loop/SKILL.md`: frontmatter (`name`, `description` naming the situations - auditing a set of agent or skill definitions, running a rotating multi-dimension audit, needing a fleet pass that does not just re-run one sweep), then the loop, the dimension roster, the briefing rules, the disk-verification rule, the dispatch-safety rule, and the termination criteria. Keep each rule adjacent to the step it governs rather than collecting them into a principles section at the end - the whole point of evidence item 6 is that a rule stated far from where it is needed gets missed.
- [ ] 4. Run `scripts/check-skills.sh` (Task 2) and apply `SKILL_CHECKLIST.md` by hand. Then run the loop once, for real, over a small target: the companion plan's `token-usage-auditor.md` and this repo's `SKILL_CHECKLIST.md`. Two rounds is enough to prove the mechanism - specifically, that round 2 receives round 1's patterns and not its instances, and that the loop reads round 1's report file rather than re-prompting. If you cannot run it, say so plainly rather than describing the design as verified.
- [ ] 5. Write the root `fleet-audit-loop.md` documentation, build, install, confirm `~/.claude/skills/fleet-audit-loop/SKILL.md` exists. Add the `README.md` table row. Commit.

---

## Task 5: Fold the durable-fix rule into the code-writing skills

**Effort:** ~1.5h expected; worst case ~2h.

**Files:** `src/code-quality/SKILL.md`, `src/incremental-implementation/SKILL.md`, `src/test-driven-development/SKILL.md`, their root `.md` documents, and their rebuilt zips.

**What goes in (evidence item 5).** A regression pass over 57 applied fixes found that none had decayed under later editing, and the reason was identifiable: roughly three quarters carried an inline comment naming the failure mode with a file and line - an argument an editor would have to delete deliberately - rather than a bare assertion that could be tidied away as noise. So: **when a fix exists because of a specific failure, the comment names that failure and cites where it happens.** Not "must be non-empty" but "empty here means the regex matched nothing and `ctest` exits 0 having run no tests - see `<file:line>`".

This sits naturally in `code-quality`'s existing principle 4 ("Comment only where the code doesn't reveal the decision. Explain why, not what."), which states the rule but not this consequence of it. Extend that principle by two or three sentences rather than adding a new one. In `incremental-implementation` and `test-driven-development` it belongs wherever each already discusses committing or finishing a change.

**The reason to state the mechanism and not just the rule:** the rule "explain why, not what" already exists and did not by itself produce durable fixes. What produced them was the comment being *load-bearing enough to be un-deletable*. That is the part worth writing down, and it is the same mechanism as the rule itself - a claim carrying an argument survives, a bare assertion does not.

**Steps:**

- [ ] 1. Read the three `SKILL.md` bodies and locate the existing home for this in each. If a skill has no natural home, leave it alone and say so - three copies of a rule where two fit is the parallel-place defect running in the opposite direction.
- [ ] 2. `grep -n 'failure mode\|why not what\|explain why' src/code-quality/SKILL.md src/incremental-implementation/SKILL.md src/test-driven-development/SKILL.md`. **Expected result:** `code-quality` matches on its principle 4; the other two probably do not match at all. This tells you which is an extension and which is an addition. If all three match strongly, the rule may already be covered and this task shrinks to a one-line clarification.
- [ ] 3. Make the edits, with the concrete example. Keep it to two or three sentences per skill; the example is the payload, the surrounding prose is not.
- [ ] 4. Rebuild and reinstall the three skills. Run `scripts/check-skills.sh`; expect exit 0.
- [ ] 5. Update each root `.md`'s `## Key ideas` with one line. Commit.

---

## Deliberately not done

- **A separate disproved-candidate skill.** `disposition-ledger` already holds the format and the gate; Task 3 extends it. Two ledgers in two files would need to be kept in step, which is the defect these plans are about.
- **A `skill-blind-spot-auditor`.** `blind-spot-auditor` in `claude-agents` is already artefact-agnostic - its subject is domain coverage gaps, not agents specifically. Mirroring it would produce a copy with the noun changed. The companion plan's Task 7 records this.
- **A `skill-overlap-auditor`.** Overlap between two skills is a conformance finding against `SKILL_CHECKLIST.md`, not a separate discipline. It is a dimension inside `skill-auditor`.
- **Deleting the inert flat `.md` symlinks before the directory installs are verified.** Task 1 removes them only after `find ~/.claude/skills -name SKILL.md` confirms the replacement loaded. Doing it in the other order leaves the user with fewer working skills than they started with.
- **Deciding whether `songwriting` belongs in a public repository.** Task 1 imports it so it is backed up and flags the question rather than answering it.
- **A `mcpServers` rule for skills.** The agent fleet bans MCP servers, but skills have no such frontmatter field, so there is nothing to ban. `SKILL_CHECKLIST.md` does not mirror the rule. Recorded here because its absence otherwise looks like an oversight to anyone comparing the two checklists.
