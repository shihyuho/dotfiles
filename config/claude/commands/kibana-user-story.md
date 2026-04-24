---
description: Distill the current conversation's Kibana usage into a reusable, environment-agnostic user-story under the agent-skills doc library
argument-hint: [optional slug or scenario hint]
---

## Task

Extract the Kibana usage that just happened (or whatever `$ARGUMENTS` points at) from the current conversation context, distill it into a reusable user-story document, and save it to:

`/Users/matt/code/github.com/softleader/agent-skills/docs/ideas/kibana/user-story/<slug>.md`

Goal: future AI sessions — operating in **any** Kibana/Elasticsearch environment — can browse this folder and, for a given scenario, immediately know the general approach, which query shape to use, and what to watch for.

## Output language

- **Body must be written in Traditional Chinese (繁體中文 / zh-TW).** Technical identifiers (field names, ES|QL keywords, command names, HTTP verbs, code blocks) stay in their original form.
- The `# Title` line and the first line of each `##` heading may stay English if that reads more naturally (e.g. `## Scenario`, `## Query strategy`), but the prose underneath is Chinese.

## Slug naming

- kebab-case English, verb-first, describes the goal. Filename stays English even though body is Chinese.
- Examples: `find-noisy-stderr-pods-by-namespace.md`, `drill-into-pod-message-patterns.md`, `map-shipper-fields-to-ecs.md`.
- If `$ARGUMENTS` is non-empty, prefer it as the slug (or as a hint to derive one).
- If a file with the chosen slug already exists, append `-2`, `-3`, etc. **Never overwrite.**

## Environment-agnostic rule (critical)

Each user-story is a reference for **future use across many environments**. It must stay generic.

- **Do not** write any value specific to the environment where this conversation happened. This includes, but is not limited to: Kibana/ES hostnames or IPs, intranet URLs, OIDC issuer URLs, organisation names, tenant names, cluster names, concrete namespace names, concrete service names, specific index prefix strings, node names, project codenames.
- **Do** replace every such value with a neutral placeholder that conveys the *shape* without the identity — e.g. `<kibana-host>`, `<es-host>`, `<tenant>`, `<cluster>`, `<namespace>`, `<service>`, `<index-family>`, `<shipper>` (instead of naming a specific log shipper vendor), `<log-shipper-field>` (instead of a concrete vendor-shaped field name).
- Where a concrete value is pedagogically necessary (e.g. illustrating that ECS uses `kubernetes.namespace` while some shippers use `kubernetes.namespace_name`), frame it as a **generic pattern example** ("some shippers nest container metadata as `<shipper-root>.namespace_name` rather than ECS `kubernetes.namespace` — confirm with a sample doc"), not as a claim about the current site.
- Curl and ES|QL snippets must use placeholder hosts (`<kibana-host>`), placeholder index patterns (`<log-index-pattern>`), and placeholder field paths. Readers paste in their own values.

## Self-contained rule

- **Do not** reference or link to other files under `docs/ideas/kibana/user-story/`. Each user-story must be readable and actionable on its own.
- If a concept overlaps with another user-story's scope, restate the minimum necessary context here rather than pointing at the sibling file.
- External references are fine: official Elastic docs, the `observability-logs-search` skill's upstream guidance, public RFCs.

## Required sections

1. `# {Human-readable scenario title}` — English title is acceptable; Chinese title also fine.
2. `## Scenario` — 1-3 句話:在什麼場合、要解決什麼問題時用這個查法。
3. `## Environment prerequisites` — 需要的前置條件,用**類別**描述而不是具體值:連線方式(公開 OAuth URL / 內網 ingress / Dev Tools Console / cookie / API key 其一或組合)、ES 版本與授權等級需求(會影響 `CATEGORIZE`、`FORK` 等功能是否可用)、log shipper 類型(ECS / 其他自訂 schema)、需要的權限。
4. `## Query strategy` — 方法論、為何這樣切分、常見陷阱(例:當 index 不符合 ECS 預設 pattern 時需先列出實際 index)。
5. `## Runnable commands` — 完整的 `curl` + ES|QL 範本,可直接貼上執行;**所有環境相關 token 皆以佔位符標記**(`<kibana-host>`、`<index-pattern>`、`<tenant>`、`<namespace>`、`<field-path>`、時間視窗等)。
6. `## Observed results` — 結果形狀的歸納摘要(欄位種類、量級範圍、訊號 vs 雜訊判讀),**不要貼原始 JSON**。
7. `## Reuse takeaways` — 下次同類場景的快速查閱提示 + 已知陷阱。

## Steps

1. 從 conversation 抽出事實:user 想查什麼、選了哪條路徑、實際跑了什麼 query、得到什麼結果、推測的根因。
2. 蒸餾:去掉一次性內容(具體 timestamp、pod hash、trace ID)以及所有環境識別字串(host、tenant、cluster、namespace、service 的真實名稱),全部替換為佔位符。
3. 取 slug,確認目標檔不存在(必要時加數字後綴)。
4. 若目標資料夾不存在,先 `mkdir -p`,再寫檔。
5. 將絕對路徑印回給 user 確認。

## Strictly forbidden

- Dumping 整段 conversation 或大段 raw JSON。
- 重述 `observability-logs-search` skill 已寫過的通用方法論 — 只記下這次場景特有的查詢形態 / 判斷邏輯 / 踩坑紀錄。
- 寫入任何 cookie、API key、token、密碼、`Authorization` header 實值。
- 寫入任何環境專屬識別字串(hostname、IP、URL、tenant / cluster / namespace / service 的實名、組織名、專案代號)。
- 引用或連結其他 user-story 檔案。
- 主觀判斷(「我覺得」),僅記錄可驗證的事實與可重複的步驟。

ARGUMENTS: $ARGUMENTS
