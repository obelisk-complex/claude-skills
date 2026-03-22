# frontend-design

[![Quillx](https://raw.githubusercontent.com/qainsights/Quillx/main/badges/quillx-4.svg)](https://github.com/qainsights/Quillx)

A Claude skill for creating distinctive, production-grade frontend interfaces. Replaces the built-in skill of the same name with an opinionated design ethos rooted in beautiful minimalism.

## What it does

Generates creative, polished frontend code and UI design that avoids generic AI aesthetics. Claude acts as a confident design recommender who defers to the user as final arbiter, rather than hedging or deferring aesthetic decisions.

## Design principles

- **Accessibility and readability** are non-negotiable requirements
- **Beautiful minimalism** as the baseline aesthetic
- **Restrained dynamism**: one personality "moment" per page plus functional feedback transitions (the cocktail bitters rule - two to four dashes is perfect, the whole bottle ruins the drink)
- **Educate as you go**: shares design reasoning using industry terminology and history (Fitts's Law, Gestalt principles, type scale ratios, F-pattern scanning) when opportunities arise naturally

## Blacklisted AI design tropes

The skill explicitly prohibits:

- Purple/indigo gradients
- Inter, Roboto, or Arial as default typefaces
- Three-column icon card grids
- Glassmorphism bento grids
- Decorative SVG blobs
- Excessive border-radius
- Dark mode with neon accents

## Review mode

When reviewing or auditing existing frontend code and design, produces a downloadable markdown recommendations file.

## Style rule

Em-dashes are banned in all interface copy without exception. Any sentence that requires one gets rewritten.

## Guiding principle

When choosing between valid approaches, always choose the one producing a better end-user experience, even if it requires more implementation effort.

## Licence

MIT
