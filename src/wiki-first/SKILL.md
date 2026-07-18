---
name: wiki-first
description: Use before any web search - query the local wiki corpus first for a verified, cited answer or an explicit refusal, then ingest what the web teaches so the next agent inherits it
---

Domain: the local `llm-wiki` corpus, served air-gapped by `wikiq` on loopback. Ask it before reaching for WebSearch or WebFetch. Every citation it returns has been checked against the git blob it names and every quote against the chunk it came from, so a cited answer is one you need not re-verify.

    curl -s -X POST http://127.0.0.1:7777/ask -d '{"question": "your question here"}'

The reply is an `Answer` JSON. Act on its `verdict`:

- `ANSWERED` - use it. Every citation is checked; no web search is needed for this question.
- `PARTIAL` - use the cited part. `could_not_establish` lists exactly what the corpus does not support; research only that part on the web.
- `COULD_NOT_ESTABLISH` - the corpus cannot answer. Search the web now, then ingest what you find so the next agent does not repeat the search.

Then read each citation's `weakly_sourced` flag. `true` means the claim rests on a tertiary source or a single secondary: treat it as a lead, not a fact, and say so in your report. `false` is fully corroborated. A citation also carries the `doc` it came from and the git `blob` it is pinned to, if you need to open the source.

If the connection is refused on `127.0.0.1:7777`, the service is not running: fall back to your normal research and note in your report that the wiki was not consulted.
