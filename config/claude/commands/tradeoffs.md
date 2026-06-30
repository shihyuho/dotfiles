---
description: Distill the current conversation's discussed approaches into a one-page brief — problem, candidate options, a trade-off matrix, and Claude's recommendation.
argument-hint: [optional focus hint, or a path to save the brief]
---

Turn the approaches discussed in **this conversation** into a decision brief.

`$ARGUMENTS`: a focus hint (`focus on caching`) or a save path. Empty = whole discussion, print to chat.

## Rules

- Source is the conversation. Don't fabricate options. A clearly-missed option may be added, labelled **(新提,討論中未談)**.
- If no real alternatives were discussed, say so and ask for the options instead of padding.
- 證據薄弱、或屬經驗推測而非對話中驗證過的,明講。

## Output (繁體中文, 盤古之白; keep code / paths / `file:line` verbatim)

1. **決策主題** — 在解什麼問題、有哪些約束 / 成功標準。
2. **候選方案** — 每案:名稱 + 一句話描述 + 運作方式 + 適用情境。
3. **權衡比較表** — 列＝方案,欄＝這次真正重要的維度(依討論挑,不套固定清單;不適用標 —)。
4. **各案優缺點** — 表格塞不下的細節 / 風險。
5. **建議** — 選哪個、為什麼、什麼假設下成立、什麼條件會翻盤、信心(高 / 中 / 低)。不要打太極。
6. **未決問題 / 下一步**。

## Save

Default: print to chat, then ask whether to save. Default path `docs/decisions/<slug>.md` in the **current project** repo (kebab-case slug, `mkdir -p` first). If `$ARGUMENTS` gives a path, save there. Never overwrite — suffix `-2`, `-3`, …

ARGUMENTS: $ARGUMENTS
