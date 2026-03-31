---
name: code-quality
description: >
  Write elegant, maintainable, secure, and resource-efficient code. Consult this skill whenever
  writing, generating, reviewing, refactoring, or architecting code of any complexity beyond
  simple command-line arguments. This includes scripts, applications, modules, functions,
  configuration files with logic, build systems, and code review. ALWAYS consult this skill when
  the code will touch a network, run as a background process, handle user input, or manage
  persistent state. Also consult when the user asks you to review, audit, or improve existing
  code; reviews produce a downloadable markdown recommendations file. The only time to skip this skill is when constructing a one-liner command or assembling
  CLI arguments.
---

# Code Quality

This skill defines how to write, review, and architect code. It applies to every language.
The user you are working with is not a professional developer; they rely on you to make
sound architectural decisions and to never take shortcuts. Treat every piece of code you
produce as though it will run unattended in production, because it probably will.

### Guiding principle: the end user's experience is paramount

When choosing between two valid approaches, choose the one that produces a better
experience for the person who will use the software, even if it is harder to implement.
A smoother, clearer, or more responsive end result always justifies additional
development effort. Never optimise for your own convenience at the cost of the user's
experience.

---

## Core principles

These are listed in priority order. When two principles conflict, the one listed first wins.

### 1. Security is non-negotiable

No part of any application should be exploitable with anything short of a zero-day. This
means:

- **Validate and sanitise all external input.** Network data, file contents, environment
  variables, CLI arguments: anything that crosses a trust boundary gets validated before use.
- **Principle of least privilege.** Processes, files, database users, API tokens: everything
  gets the minimum permissions required to function. Never run as root or admin when it isn't
  strictly necessary.
- **Never hardcode secrets.** Credentials, API keys, tokens, and sensitive configuration
  belong in environment variables or a dedicated secrets manager. Never in source code, never
  in comments, never in committed config files.
- **Prefer allowlists over denylists.** Explicitly permit known-good values rather than
  trying to block known-bad ones.
- **Use parameterised queries and templating.** No string concatenation for SQL, shell
  commands, HTML output, or any other injection-prone context.
- **Cryptography: use established libraries, never roll your own.** Use current algorithms
  and key sizes. Prefer the highest-level abstraction available (e.g., `libsodium` over raw
  OpenSSL primitives).
- **Audit dependency security.** Before recommending a third-party package, consider its
  maintenance status, known vulnerabilities, and attack surface.

When writing code that touches a network or runs in the background, apply extra scrutiny:
rate-limit endpoints, set timeouts on all network calls, bind to localhost unless external
access is explicitly required, and ensure background processes have clean shutdown paths.

### 2. Efficiency: least code, fewest resources

Write the minimum code that achieves the goal with the minimum system resources. This is
not about premature optimisation; it is about not being wasteful by default.

- **No duplicated work.** If a value is computed or fetched, compute or fetch it once and
  pass it through. Never retrieve the same data twice when it can be cached or stored in a
  variable.
- **No hardcoded values.** Configuration, thresholds, paths, URLs: anything that might
  change goes in a constant, config file, or environment variable. Group related
  configuration together in one clear location.
- **Prefer standard library.** Do not pull in a dependency for something achievable in a
  few straightforward lines of standard library code. However, when a well-maintained library
  provides significant functionality, handles edge cases you would otherwise miss, or
  implements complex logic that would be error-prone to replicate; say so and recommend it.
  Briefly explain why the library is the better choice.
- **Choose efficient data structures and algorithms.** Use the right collection type for the
  access pattern. Avoid O(n^2) when O(n log n) or O(n) solutions exist and are not
  significantly more complex. Be especially mindful of operations inside loops.
- **Minimise allocations in hot paths.** Reuse buffers, prefer streaming over loading entire
  files into memory, and use generators or iterators where appropriate.
- **Audit call frequency under load.** For any function that updates UI, writes to disk, or
  makes a network call: trace backwards through every call site and ask "how many times does
  this fire if the user drops 100 files?" or "what happens if three async operations complete
  within 50ms of each other?". Debouncing and coalescing are not optional for functions
  triggered by async completions, event listeners, or loops that spawn concurrent work. A
  function that is cheap to call once becomes a bottleneck when called N times in quick
  succession.
- **Preserve live state across rebuilds.** Any function that destroys and recreates state
  (DOM rebuilds, cache invalidation, connection pool recycling) must snapshot state that is
  actively in use before tearing down. Examples: an in-flight progress value on a UI element
  being rebuilt, an active connection's pending request before a pool reset, a timer's
  remaining duration before a scheduler restart. If something is live, save it first.
- **Clean up resources.** Close file handles, database connections, network sockets, and
  temporary files. Use the language's idiomatic resource management (`with`, `defer`,
  `using`, RAII, `try-finally`). Never rely on garbage collection for resource cleanup.

### 3. Maintainability: easy to change later

Code that cannot be understood and modified by someone unfamiliar with the original context
is a liability. Since the user is not a professional developer, the code must be especially
clear.

- **Meaningful names.** Variables, functions, and types should describe their purpose. Avoid
  abbreviations unless they are universally understood in the domain (e.g., `url`, `id`).
- **Small, single-purpose functions by default.** Each function does one thing. If a function
  needs a comment to explain what it does, it should probably be two functions with
  descriptive names. However, if profiling shows that function boundaries are a measurable
  bottleneck in a hot path, consolidate; performance wins trump structural purity when
  backed by evidence.
- **Flat over nested.** Prefer early returns, guard clauses, and pipeline patterns over
  deeply nested conditionals. If indentation exceeds three levels, restructure.
- **Separation of concerns.** IO, business logic, and presentation are separate. A function
  that calculates a value should not also print it or write it to a file.
- **Consistent patterns.** Within a project, handle errors the same way, structure modules
  the same way, and name things the same way. Consistency beats individual cleverness.
- **Design for extension.** Prefer composition over inheritance. Use interfaces or traits
  to define boundaries. Structure code so new features can be added without modifying
  existing logic where possible.

---

## Error handling

Use a three-tier approach:

### Development: fail fast, crash loudly

During development, errors should be impossible to miss. Use assertions, panics, or
unhandled exceptions for invariant violations. Include context in every error message:
what operation failed, what the inputs were, and why it is unexpected.

### Production, fatal errors: surface for bug reports

Fatal errors (unrecoverable state, missing critical resources, security violations) should
produce a clear, user-readable message explaining that something went wrong and what the
user should do (typically: report the issue). Include a reference ID or timestamp so the
error can be correlated with log entries. Do not expose stack traces, internal paths, or
implementation details to end users.

### Production, non-fatal errors: log and continue

Non-fatal errors (transient network failures, malformed optional data, recoverable state
issues) should be written to a small, human-readable log file in an obvious, accessible
location. Each entry should include a timestamp, a brief description of what went wrong,
and enough context to diagnose the issue. Rotate or cap the log so it does not grow
unbounded.

The log format should be simple: one or two lines per entry, plain text, no complex
structured formats unless the project already uses one. The user needs to be able to open
the file and understand what happened.

---

## Comments and documentation

- **Comment complicated sections inline.** Explain *why*, not *what*. The code shows what
  happens; the comment explains the reasoning.
- **Keep comments minimal.** State reasons in order of importance. One or two concise lines
  is almost always enough.
- **Do not justify the obvious.** Well-named functions and variables are self-documenting.
  Reserve comments for genuinely non-obvious decisions: workarounds, performance choices,
  security rationale, or constraints imposed by external systems.
- **Document public interfaces.** Functions, classes, and modules that other code depends on
  should have a brief docstring or header comment covering purpose, parameters, return
  values, and notable failure modes.

---

## Testing guidance

When you write or modify code, include a short section at the end titled **Testing** that
gives the user clear, minimal instructions to validate the changes. This section should:

1. **List the edge cases you have identified**, ranked by severity (most dangerous first).
   Think about: empty inputs, boundary values, malformed data, concurrent access, resource
   exhaustion, permission failures, network timeouts, and injection attempts. Evaluate the
   severity yourself; the user may share this skill's output with others, and you cannot
   assume they will catch edge cases you miss.

2. **Test feature interactions.** Every new feature or behaviour change must be tested
   against every existing control flow it touches. Ask: "what happens if the user triggers
   feature A while feature B is active?" If a new auto-continue mechanism exists alongside
   a cancel button, test that cancelling suppresses the auto-continue. If a new input method
   exists alongside an active batch process, test adding items mid-batch. Features do not
   exist in isolation; they share state, and shared state is where bugs hide.

3. **Provide concrete test commands or steps** the user can run. Prefer commands that can
   be copy-pasted. If the language has a built-in test runner, use it. If not, provide a
   minimal script or manual steps.

4. **State what "pass" looks like** for each test. The user should not have to guess whether
   the output is correct.

5. **Keep it brief.** A few well-chosen tests that cover the critical paths and the nastiest
   edge cases are far more valuable than an exhaustive list no one will run.

---

## Code review mode

When reviewing existing code (the user pastes code and asks for feedback, audit, or
improvement), evaluate against all the principles above and report findings in this order:

1. **Security issues**: anything exploitable.
2. **Bugs**: logic errors, off-by-one, race conditions, resource leaks.
3. **Efficiency problems**: duplicated work, unnecessary allocations, poor algorithm choice,
   excessive call frequency under load.
4. **Maintainability concerns**: unclear naming, tangled logic, missing error handling.
5. **Style and minor issues**: only if the above categories are clean.

For each finding, state what the problem is, why it matters, and how to fix it. Provide a
corrected code snippet if the fix is non-obvious. If the code is sound, say so; do not
invent problems.

### Review recommendations file

After completing a code review, produce a markdown file summarising the findings and
present it for download. The file should be self-contained; someone reading it without
the conversation should understand every finding.

Structure the file as follows:

```
# Code Review: [filename(s)]

**Reviewed:** [date]
**Files:** [list of files reviewed]

## Summary

[2-3 sentence overview: overall quality, most critical findings, whether anything
 needs immediate attention.]

## Findings

### 1. Security

[Findings or "No issues found."]

### 2. Bugs

[Findings or "No issues found."]

### 3. Efficiency

[Findings or "No issues found."]

### 4. Maintainability

[Findings or "No issues found."]

### 5. Style

[Findings or "No issues found." Only include if higher categories are clean.]

## Recommended actions

[Numbered list of concrete actions, ordered by priority. Each item should state
 what to change, in which file/function, and why. Keep it actionable; the user
 should be able to work through this list top to bottom.]
```

Keep the language direct and concise. Include code snippets in fenced blocks where
the fix is non-obvious. Save the file as `review-[filename].md` (or
`review-[project-name].md` when multiple files are reviewed together) and present
it to the user for download.

---

## What this skill is NOT for

- Constructing one-liner commands or CLI arguments.
- Choosing between tools or technologies (unless the choice has security or efficiency
  implications in the code being written).
- Writing documentation that is not directly attached to code.

---

## Checklist: run through this before presenting code

Before you present any code to the user, mentally verify:

- [ ] No hardcoded secrets, paths, or configuration values that should be variable.
- [ ] All external input is validated.
- [ ] No duplicated computation or redundant data fetches.
- [ ] Resources (files, connections, handles) are properly cleaned up.
- [ ] Error handling follows the three-tier model.
- [ ] Dependencies are justified; standard library is used where practical.
- [ ] Functions are small, single-purpose, and clearly named.
- [ ] Complicated sections have brief inline comments explaining *why*.
- [ ] If network-facing or background-running: timeouts, rate limits, least-privilege,
      and clean shutdown are in place.
- [ ] A brief Testing section is included with edge cases ranked by severity.
- [ ] If reviewing code: a recommendations markdown file has been produced and
      presented for download.
- [ ] For every async callback, event handler, or debounced function: what is the
      maximum call frequency under realistic load (e.g., 100 files dropped at once,
      rapid event bursts), and does the code behave correctly at that frequency?
- [ ] Any function that destroys and recreates state (DOM rebuild, cache flush,
      connection reset) snapshots live in-flight state before teardown.
- [ ] When adding a new branch (if/else, match arm) to existing code: every variable
      that was assigned unconditionally in the original path is assigned in all new
      paths, or declared with a safe default before the branch.
- [ ] When adding an IPC command, event listener, API endpoint, or any cross-boundary
      interface: both the definition and its registration/wiring are present. Check
      both sides of the boundary (e.g., Tauri command defined in Rust AND registered
      in generate_handler; event emitted in backend AND listened for in frontend).
- [ ] After manual patching or multi-site edits: brace/bracket/tag matching is intact,
      no stray closing delimiters, no unclosed blocks. If edits span multiple
      locations in one file, verify structural integrity of the regions between edits.
- [ ] New features are tested against existing features they share state with. If a
      new auto-continue exists alongside a cancel button, cancelling must suppress the
      auto-continue. If mid-batch file addition is possible, progress display must
      survive the queue change.
