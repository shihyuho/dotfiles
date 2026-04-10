---
id: fzf-with-nth-narrows-search-field
date: 2026-04-10
scope: feature
tags: [fzf, shell, search, display, quirk]
source: bug-fix
confidence: 0.5
---

# fzf `--with-nth` transforms the line before `--nth` applies — it narrows search too

## Context

Building an fzf-based interactive list (gdiff tree view) with multi-field
tab-delimited lines. Goal: display only the visual portion (field 1), but still
let users type to filter by file path (field 2) or directory path (field 3).

## Mistake

Set `--delimiter=$'\t' --with-nth=1 --nth=2,3` on fzf 0.70, expecting display
to hide fields 2-3 while search still hits them. Search returned zero matches
for any file content. Filter-as-you-type was broken.

Root cause: `--with-nth` transforms the line BEFORE `--nth` applies. After
`--with-nth=1`, every line is reduced to just field 1, so `--nth=2,3` targets
fields that no longer exist.

The fzf manpage describes `--with-nth` as "Transform the presentation of each
line" without warning that search is also scoped to the transformed line.
Empirical test:

```bash
printf 'hello\tworld\ttest\n' | fzf --delimiter=$'\t' --with-nth=1 --filter='world'
# → nothing (world is in field 2, but line has been reduced to "hello")

printf 'hello\tworld\ttest\n' | fzf --delimiter=$'\t' --with-nth=1 --filter='hello'
# → hits (hello is field 1, the only remaining field)
```

## Lesson

`--with-nth=<display-fields>` narrows BOTH display AND search scope. You cannot
search a hidden field via `--nth`. If you need the user to find content that
isn't visible, you must restructure:

- **Put the searchable text inside the displayed field** (e.g. tree mode
  showing the basename is searchable; embedding the full path in field 1
  makes the full path searchable)
- **Use `{n}` (line number) for binding lookup** if you need to extract
  non-visible data per selection — the binding can then consult a side file
  keyed by line number
- **Skip `--with-nth` entirely** and accept that tabs render as whitespace
  gaps in the display

## When to Apply

Whenever you build an fzf list with tab- or delimiter-separated per-line
metadata and reach for `--with-nth` to hide columns. Before committing to
`--with-nth`, ask: "does the user need to search by the fields I'm about to
hide?" If yes, `--with-nth` is the wrong tool — the fields must stay visible,
or the data must live in a side channel accessed via `{n}`.
