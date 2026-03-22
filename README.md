# claude-skills

[![Quillx](https://raw.githubusercontent.com/qainsights/Quillx/main/badges/quillx-4.svg)](https://github.com/qainsights/Quillx)

A collection of custom skills for Claude, built to fill gaps in the default toolset and encode opinionated best practices.

## Skills

| Skill | Description |
|---|---|
| [code-quality](skills/code-quality/README.md) | Language-agnostic code standards, review mode, and testing guidance. Refuses to write code it considers wrong. |
| [frontend-design](skills/frontend-design/README.md) | Production-grade frontend interfaces with a beautiful minimalist design ethos. Replaces the built-in skill. |
| [github-actions](skills/github-actions/README.md) | CI/CD workflows, reusable workflows, composite actions, and custom actions with security baked in. |
| [pcb-engineer](skills/pcb-engineer/README.md) | Full PCB design lifecycle from consulting through manufacturing prep. KiCad 8+, educational by default. |
| [3d-print-design](skills/3d-print-design/README.md) | 3D-printable parts and enclosures across FDM, resin, SLS, and metal processes. Pairs with pcb-engineer. |
| [cosmos-compose](skills/cosmos-compose/README.md) | Cosmos Cloud container configs, reverse proxy routes, OpenID/SSO, and platform administration. |

## Installation

Download the `.skill` file for any skill you want and install it via Claude's skill management interface.

## Licence

MIT