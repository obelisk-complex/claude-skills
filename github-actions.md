# github-actions

[![Quillx](https://raw.githubusercontent.com/qainsights/Quillx/main/badges/quillx-4.svg)](https://github.com/qainsights/Quillx)

A Claude skill for generating production-grade GitHub Actions workflows, reusable workflows, composite actions, and custom JavaScript/Docker actions.

## What it does

Generates CI/CD pipeline YAML with security and maintainability baked in from the start. Covers the full GitHub Actions surface: workflow files, reusable workflows, composite actions, custom JS and Docker actions, self-hosted runner configuration, and debugging failing workflows.

## Opinionated defaults

The skill enforces best practices by default:

- **SHA-pinned actions** with human-readable tag comments (model looks up current SHAs via web search at generation time rather than relying on stale hardcoded values)
- **Least-privilege permissions** declared at workflow level
- **Explicit shell** (`bash`) and `set -eo pipefail` semantics
- **Concurrency control** to prevent wasted runner minutes
- **Timeouts** on every job (the 6-hour default is never acceptable)
- **OIDC federation** preferred over static cloud credentials
- **GitHub Environments** with protection rules for deployments
- **Repository rulesets** recommended over legacy branch protection

## Includes

- **SKILL.md** (~510 lines): core principles, workflow structure, matrix builds, reusable workflows, composite actions, custom actions, self-hosted runners, debugging guide, security checklist, review mode
- **references/recipes.md** (~530 lines): 12 copy-adaptable recipes for Python CI, Docker build/push, Perl CI, multi-platform containers, release automation, OIDC deploys (AWS/GCP/Azure), Dependabot auto-merge, CodeQL scanning, Terraform plan/apply, Node/TypeScript CI

## Ecosystem coverage

Ecosystem-agnostic with specific knowledge for Python, Docker, Perl, Node/TypeScript, and Terraform. Designed to handle anything.

## Licence

MIT
