# Skill Definition Checklist

Every skill in this collection should satisfy the following. Use it when writing
a new skill or auditing an existing one.

The task is to compare a skill against this standard and list the discrepancies,
not to find fault. Where an item does not apply, say so and move on; a skill that
consciously departs from an item and says why is conforming, not failing.

**Two gates, and only two.** `scripts/check-skills.sh` mechanically checks the
Packaging section and nothing else. Every other item needs a reader. Each section
below states which applies. Do not read an unticked box as "unchecked by the
script" unless the section says the script checks it.

## Packaging (CRITICAL)

**Gated by `scripts/check-skills.sh`.** A skill that does not load has no other
property worth auditing, and fourteen skills were in that state on 2026-07-18
with nothing reporting it.

- [ ] `src/<name>/SKILL.md` exists
- [ ] Frontmatter is a YAML block at line 1 carrying `name` and a non-empty `description`
- [ ] `name` matches its directory exactly
- [ ] `<name>.md` exists at the repo root
- [ ] `skills/<name>.skill` exists and contains `<name>/SKILL.md` at that path
- [ ] The archive matches `src/<name>/`, ignoring git-ignored files

The last item is the one that closes the loop. `build-skills.sh` does not
install and `install-skills.sh` does not rebuild, so before this check nothing
noticed an edit to `src/` that was never packaged; the caller kept loading the
old body. Each skill lives in three places (root `.md`, `skills/<name>.skill`,
installed `~/.claude/skills/<name>/SKILL.md`) and they must move together.

Run it after any edit under `src/`:

```
scripts/check-skills.sh              # all skills
scripts/check-skills.sh code-quality # one
```

## Trigger quality

**Needs a reader.** The script confirms `description` is non-empty; no script can
judge whether it matches.

- [ ] Names the situations the skill applies to, in the words a user would use
- [ ] Uses the caller's vocabulary, not the skill's internal jargon
- [ ] Where the skill is easy to confuse with a sibling, the description says which case is which

`description` is the entire matching surface: it is what a caller sees when
deciding whether to invoke, and the body is never consulted in that decision. A
description that describes what the skill *contains* rather than when to *reach
for it* will not be found by someone who needs it.

Compare `disposition-ledger`, which names the specific agents whose output it
handles (`plan-auditor`, `code-auditor`, `pr-reviewer`, `/code-review`) and the
failure it prevents (findings "evaporating into conversation"), against a bare
"Use for tracking findings". The first matches a caller's actual situation; the
second matches nothing in particular.

## Consumer and reach

**Needs a reader.** This is the item most likely to be silently wrong, because a
skill that fails it looks entirely correct on the page.

- [ ] The skill states whether its consumer is the invoking orchestrator or a dispatched agent
- [ ] Where rules are meant to reach a dispatched agent, the skill says how they get there

Skills are invoked through the `Skill` tool. All 55 agents in
`/media/owner/Workspace/claude-agents/agents/` declare an explicit `tools:` list
and **not one of them includes `Skill`** (verify with
`grep '^tools:' /media/owner/Workspace/claude-agents/agents/*.md`). Only a caller
holding `Skill` (an orchestrator, or an agent with `tools: *`) can load a skill
at all.

The consequence is narrow and worth stating precisely: a skill's rules cannot
bind a dispatched fleet agent by the agent reading the skill, because the agent
cannot invoke it. A skill written as though the auditor it dispatches will read
its rules is silently broken. This is not a reason to avoid skills that dispatch
agents; it is a reason for such a skill to relay its rules into the brief.

`fleet-qa-loop` is the worked example. It dispatches a fleet, and instead of
assuming those agents share its rules it makes the orchestrator carry them:
"**Every dispatched agent MUST be instructed to:**" followed by the five rules,
and, on the live-system bar, "State the bar in the brief - **an agent will not
infer it**", with ready-made brief boilerplate. The rules reach the agent because
the orchestrator writes them into the brief, which is the only route available.

## Scope boundary

**Needs a reader.**

- [ ] States its boundary against its nearest sibling skill, near the top
- [ ] Says which skill governs which case, rather than only asserting a difference

`disposition-ledger` does this in one paragraph: `receiving-code-review` governs
*how* to evaluate one piece of feedback, this skill governs *whether the set is
fully resolved*. It then reinforces the split where the two could be confused
("Deciding *how hard* to verify a given finding is the job of
`superpowers:receiving-code-review`, not this skill"). A reader who lands on
either skill learns where the other one starts.

## Context cost

**Needs a reader.** No script can judge whether length is earned.

The body loads into the caller's context on every invocation, so length is a
direct cost to every user of the skill, paid whether or not the relevant section
is the one they needed.

- [ ] Every section is material a caller plausibly needs on a typical invocation
- [ ] Catalogue and lookup material (tables consulted one row at a time, per-case
      reference data, long enumerations) sits in `references/`, not the body
- [ ] Bodies over 15 KB either justify each section as load-on-every-call, or split

Sizing against the corpus: the median skill is about 11 KB and nine exceed 15 KB.
Treat under 5 KB as unquestioned, 5-15 KB as normal, and over 15 KB as owing an
explanation. The threshold is a prompt to look, not a verdict.

The test that discriminates: **for the skill's most common single task, what
fraction of the body does the caller actually use?** Reference material fails
this by construction, because each invocation needs one entry from it.

`pcb-engineer` and `svg-illustrator` cover comparably catalogue-heavy technical
domains and resolve it oppositely. `pcb-engineer` keeps a 12.5 KB body and moves
six catalogues (`design-rules`, `component-selection`, `connector-pinouts`,
`common-circuits`, `kicad-formats`, `manufacturing-checklist`) into
`references/`. `svg-illustrator` is 32.9 KB with no `references/` directory at
all. Four skills use `references/`; the mechanism exists for exactly this
purpose.

## Body content

**Needs a reader.**

- [ ] Opens with domain framing, not an expert persona
- [ ] Where the skill is procedural, steps are ordered with checkable outputs
- [ ] Where the skill is a gate, the rule that gates is stated once, unambiguously, and early
- [ ] Rules carry the reasoning or the incident that produced them, where it is not self-evident
- [ ] Worked examples show a passing case and a failing one, not only the passing case

The contrast pair is what makes an example teach. `disposition-ledger` follows
its ledger table with the rejection that would not satisfy the gate and says why
("a bare assertion wearing a disposition's clothes"). A skill showing only good
output leaves the reader to infer the boundary.

## Self-verification

**Needs a reader.**

- [ ] Skills that produce an artefact carry a verification step or checklist before the output section
- [ ] Verification names concrete commands or observations, not "check your work"
- [ ] Gates state what a failing result looks like, so a passing result means something

A gate that cannot fail is read as coverage and is worse than no gate: an audit
found a `ctest` invocation exiting 0 when its regex matched nothing, so the gate
passed having run no tests. When adding a check to a skill, confirm it can report
failure before claiming it as a gate.

Where a skill asserts facts, it should invite abstention explicitly: an unverified
claim marked uncertain is more useful than a confident guess.

## Root documentation

**Partly gated.** `check-skills.sh` confirms `<name>.md` exists; its shape and
its agreement with the skill body need a reader.

The house shape, as the corpus actually uses it (verified across 35 documents on
2026-07-18):

- [ ] `# <name>` heading matching the filename (35/35)
- [ ] Quillx badge line, with a sentence on what a human defined and refined (35/35)
- [ ] Prose description of the skill (35/35)
- [ ] `## What it does` (34/35)
- [ ] Skill-specific middle sections
- [ ] `## Licence` closing the file (32/35)

There is no `## Installation` convention; two files have one and the README
carries the real instructions. Do not add one.

- [ ] Where the root doc mirrors the skill body, an edit to one is made to both

This last item needs a reader and deliberately has no script. Of the 35 skills,
about 20 have root docs that are the skill body plus a header and footer, and
about 8 are genuinely independent artefacts written for a different audience. A
mechanical body-equality check would therefore fail those 8 on every run, and
suppressing them needs a manifest of which skills are mirrors, which is a fourth
copy of the same information, drifting exactly like the three this plan exists to
fix. So the script checks that the root doc exists; a reader decides whether it
should have moved. `code-quality` has already drifted this way and is being
handled separately.

## Humane prompting gate

- No language that fails the ten-test checklist in `HUMANE_PROMPTING.md`
  (canonical: `llm-wiki/wiki/concepts/humane-psychological-prompting.md`).
  The most common failure in this fleet is adversarial role assignment toward
  the author: "hostile reviewer", "hostile acceptance tester", "aggressive
  critic". Adversarial framing toward the artefact or the claim under test is
  correct and expected in audit and red-team skills; toward the author or any
  person it is not.
- Grep before merge as a tripwire, not a verdict:
  `grep -rniE "hostile|aggressive critic|adversar" src/`
  Every hit is adjudicated against the target test above. "Hostile input",
  "adversarial review of a claim" and the red-team fleet's probing language all
  pass; "hostile reviewer" and "aggressive critic" aimed at an author do not.
  The grep finds where the question must be asked. It does not answer it.

## Style rules

**Needs a reader**, with one tripwire.

- Use single hyphens for dashes in prose, never em-dashes or double hyphens.
  Tripwire: `grep -rlP '\x{2014}' src/*/SKILL.md` (the escape keeps this file
  from matching its own pattern). This is mechanically checkable and
  deliberately not wired into `check-skills.sh`: 21 of 35 bodies currently hit it,
  and a gate that is red the day it lands gets suppressed rather than fixed. Add
  it to the script once the corpus is clean, so it starts green and any new hit
  is a real regression.
- British English
- Single blank line between sections, never double
- Keep the skill project-agnostic unless it is deliberately house-specific
  (`readme-conventions`, `songwriting` and `upstream-prs-to-hermes-agent` are,
  and say so)
- Preamble is 2-3 sentences max, then straight to the content
