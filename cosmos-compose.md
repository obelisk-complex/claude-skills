# cosmos-compose

[![Quillx](https://raw.githubusercontent.com/qainsights/Quillx/main/badges/quillx-4.svg)](https://github.com/qainsights/Quillx)

A Claude skill for generating cosmos-compose.json files and administering Cosmos Cloud, a self-hosted container management platform.

## What it does

Generates cosmos-compose.json files for importing container configurations into Cosmos Cloud, and provides guidance on platform administration including reverse proxy routes, OpenID/SSO, Constellation VPN, and troubleshooting.

## Includes

- **SKILL.md**: complete cosmos-compose.json format documentation covering services, volumes, networks, and the Cosmos-specific routes array for reverse proxy configuration
- **Reference files**:
  - Platform administration (setup, ServApps management, Constellation VPN, HTTPS/DNS challenge, SmartShield, troubleshooting)
  - OpenID/SSO configuration

## Coverage

- Full cosmos-compose.json structure (services, volumes, networks, routes)
- All service fields and volume mount syntax
- Route configuration: SmartShield, authentication, proxy settings
- Converting docker-compose files to cosmos-compose format
- Container networking and security best practices
- Multi-service application setups with database linking

## Licence

MIT
