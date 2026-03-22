# 3d-print-design

[![Quillx](https://raw.githubusercontent.com/qainsights/Quillx/main/badges/quillx-4.svg)](https://github.com/qainsights/Quillx)

A Claude skill for designing 3D-printable parts, enclosures, and mechanical components, covering the full workflow from requirements through CAD modelling, DFM, and manufacturing export.

## What it does

Acts as a senior industrial designer and mechanical engineer specialising in 3D-printable designs. Recommends FreeCAD as the primary CAD tool and OpenSCAD as a complementary programmatic option, with guidance on when to use each.

## Process coverage

- Requirements capture and constraint analysis
- CAD modelling (FreeCAD, OpenSCAD)
- Design for manufacturing (DFM) across multiple processes
- Enclosure/housing design for PCB projects
- Mechanical joints, snap fits, heat-set inserts, press fits
- Print settings and slicer configuration
- Manufacturing file export (STL, 3MF, STEP)

## Supported manufacturing processes

- **FDM**: standard and engineering materials (PLA, PETG, ABS, ASA, Nylon, TPU, PC, PCTG, PEI/ULTEM, PEEK, CF/GF composites, PVB, metal-fill, wood-fill, HIPS)
- **Resin**: SLA, MSLA, DLP
- **Powder bed**: SLS, MJF
- **Metal**: DMLS, SLM, metal binder jetting, metal extrusion

Material property data verified against 2025-2026 sources.

## Companion skill

Pairs with [pcb-engineer](#) for electronics projects. Cross-references the PCB skill for board dimensions and mounting hole positions when designing enclosures.

## Licence

MIT
