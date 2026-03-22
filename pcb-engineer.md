# pcb-engineer

A Claude skill for PCB design and circuit engineering, covering the full product lifecycle from initial consulting through to manufacturing file preparation.

## What it does

Acts as a senior electrical engineer and PCB designer, guiding you through a six-phase lifecycle: requirements and consulting, architecture and block diagrams, schematic design, component selection and BOM generation, PCB layout, and manufacturing preparation. Primary EDA target is KiCad 8+.

Designed to be maximally educational, explaining the reasoning behind every design decision. Suitable for beginners through to experienced engineers wanting a knowledgeable second opinion.

## Includes

- **SKILL.md**: main skill covering the full design lifecycle
- **Reference files**:
  - KiCad file formats with full S-expression syntax
  - Design rules with IPC-2152 trace width tables and fab capabilities
  - Common circuits (regulators, USB, protection, decoupling)
  - Component selection decision trees
  - Connector pinouts
  - Manufacturing checklist (DFM/DFA)
- **Scripts**:
  - Python BOM generator producing XLSX output with primary and two alternative parts per line item

## Key design decisions

- BOM alternative parts priority: pin-compatible drop-in first, then functional equivalents, then cost, then availability
- Manufacturing targets: JLCPCB/PCBWay with generic rules noted
- Explains everything: the skill assumes you want to learn, not just receive files

## Companion skill

Pairs with [3d-print-design](#) for enclosure design. The 3D print skill cross-references this one for board dimensions and mounting hole positions.

## Licence

MIT
