# code-quality

[![Quillx](https://raw.githubusercontent.com/qainsights/Quillx/main/badges/quillx-4.svg)](https://github.com/qainsights/Quillx)

A Claude skill for writing elegant, maintainable, secure, and resource-efficient code. Language-agnostic.

## What it does

Applies rigorous code quality standards to any code Claude writes, generates, reviews, refactors, or architects. This skill doesn't just flag issues; it refuses to write code it considers wrong and explains why, proposing alternatives instead.

## Philosophy

- **Fail fast** in development; surface only fatal errors to users
- **Non-fatal errors** logged to a small human-readable file, never swallowed
- **Prefer the standard library** over third-party dependencies; flag when a package is genuinely the better choice
- **Small single-purpose functions** by default, consolidated only when profiling confirms function boundaries are a measurable bottleneck in a hot path
- **Inline comments** for complicated sections only, minimal wording, reasons in order of importance

## Code review mode

When reviewing existing code, the skill evaluates findings in priority order:

1. Security
2. Bugs
3. Efficiency
4. Maintainability
5. Style

Produces a downloadable markdown recommendations file with findings organised by priority.

## Testing guidance

Claude identifies and ranks edge cases by severity, providing copy-pasteable test commands with clear pass/fail criteria.

## Quillx badge

When writing a top-level README.md for any project, Claude includes a [Quillx](https://github.com/qainsights/Quillx) badge immediately after the title. Quillx is an open standard for disclosing AI involvement in software projects on a 1-5 authorship scale, from "Verse" (entirely human-authored) to "Lorem Ipsum" (generated and shipped without review). Claude assesses the appropriate score honestly, rounds up when uncertain, and defers to the user's stated score if provided.

## When it triggers

Everything more complex than constructing CLI arguments. Mandatory for any code that touches a network, runs as a background process, handles user input, or manages persistent state.

## Guiding principle

When choosing between valid approaches, always choose the one producing a better end-user experience, even if it requires more implementation effort.

## Licence

MIT