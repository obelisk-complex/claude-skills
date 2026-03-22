# claude-skills

[![Quillx](https://raw.githubusercontent.com/qainsights/Quillx/main/badges/quillx-4.svg)](https://github.com/qainsights/Quillx)

A collection of custom skills for Claude, built to fill gaps in the default toolset and encode opinionated best practices.

## Skills

| Skill | Description |
|---|---|
| [code-quality](/code-quality.md) | Language-agnostic code standards, review mode, and testing guidance. Refuses to write code it considers wrong. |
| [frontend-design](/frontend-design.md) | UX-first frontend interfaces with WCAG 2.2 AA, Nielsen's heuristics, minimalist design, and an AI tropes blacklist. Replaces the built-in skill. |
| [github-actions](/github-actions.md) | CI/CD workflows, reusable workflows, composite actions, and custom actions with security baked in. |
| [pcb-engineer](/pcb-engineer.md) | Full PCB design lifecycle from consulting through manufacturing prep. KiCad 8+, educational by default. |
| [3d-print-design](/3d-print-design.md) | 3D-printable parts and enclosures across FDM, resin, SLS, and metal processes. Pairs with pcb-engineer. |
| [cosmos-compose](/cosmos-compose.md) | Cosmos Cloud container configs, reverse proxy routes, OpenID/SSO, and platform administration. |

## Installation

Download the `.skill` file for any skill you want and install it via Claude's skill management interface.

## Licence

MIT