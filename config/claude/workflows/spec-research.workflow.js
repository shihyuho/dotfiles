/**
 * spec-research — personal dynamic workflow (Claude Code research preview)
 *
 * Installed via dotfiles as ~/.claude/workflows/spec-research.workflow.js, so it
 * runs as /spec-research in every project.
 *
 * Given the requirement context gathered while clarifying with the user (passed
 * in via `args`), it researches existing conventions, drafts a spec from several
 * angles in parallel, judges them adversarially, and returns one synthesized
 * best-recommendation draft.
 *
 * It does NOT replace clarification or human sign-off — a workflow cannot prompt
 * the user mid-run. Clarify requirements in the main session first, pass them as
 * args, then confirm the recommended draft before saving SPEC.md.
 *
 * args: the requirement context from clarification. Free text or a structured object, e.g.
 *   { objective, users, features, constraints, techHints }
 * If args is omitted, the script asks agents to infer context from the conversation/repo,
 * but supplying it produces far better drafts.
 *
 * Requires Claude Code v2.1.154+ with dynamic workflows enabled (research preview).
 */

export const meta = {
  name: 'spec-research',
  description: 'Research and draft a spec from multiple angles, judge them, synthesize the best recommendation',
  phases: [
    { title: 'Research', detail: 'scan existing conventions, then draft the spec from several angles' },
    { title: 'Judge', detail: 'score each draft on completeness, testability, boundary clarity' },
    { title: 'Synthesize', detail: 'merge into one best-recommendation spec with a trade-off table' },
  ],
}

// Six core areas of a spec, plus success criteria / open questions / surfaced assumptions.
const SPEC_SCHEMA = {
  type: 'object',
  properties: {
    objective: { type: 'string', description: 'What we are building and why; who the user is; what success looks like' },
    techStack: { type: 'string', description: 'Framework, language, key dependencies with versions' },
    commands: { type: 'string', description: 'Full build/test/lint/dev commands with flags' },
    projectStructure: { type: 'string', description: 'Directory layout with descriptions' },
    codeStyle: { type: 'string', description: 'One real snippet + key naming/formatting conventions' },
    testingStrategy: { type: 'string', description: 'Framework, test locations, coverage, test levels' },
    boundaries: {
      type: 'object',
      properties: {
        always: { type: 'array', items: { type: 'string' } },
        askFirst: { type: 'array', items: { type: 'string' } },
        never: { type: 'array', items: { type: 'string' } },
      },
      required: ['always', 'askFirst', 'never'],
    },
    successCriteria: { type: 'array', items: { type: 'string' }, description: 'Specific, testable done conditions' },
    openQuestions: { type: 'array', items: { type: 'string' } },
    assumptions: { type: 'array', items: { type: 'string' }, description: 'Assumptions made while drafting — surface them' },
  },
  required: ['objective', 'commands', 'projectStructure', 'codeStyle', 'testingStrategy', 'boundaries', 'successCriteria'],
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    completeness: { type: 'number', description: '1-5: how fully it covers the six core areas' },
    testability: { type: 'number', description: '1-5: how concrete and testable the success criteria are' },
    boundaryClarity: { type: 'number', description: '1-5: how clear Always/Ask-first/Never are' },
    strengths: { type: 'array', items: { type: 'string' } },
    weaknesses: { type: 'array', items: { type: 'string' } },
    risks: { type: 'array', items: { type: 'string' } },
  },
  required: ['completeness', 'testability', 'boundaryClarity', 'strengths', 'weaknesses'],
}

const ANGLES = [
  { key: 'mvp-first', brief: 'smallest spec that ships value fast; defer everything deferrable' },
  { key: 'risk-first', brief: 'lead with the riskiest assumptions and unknowns; spec to de-risk them early' },
  { key: 'extensibility-first', brief: 'spec for change; clear seams, boundaries, and room to grow' },
]

const ctx = args
  ? JSON.stringify(args)
  : '(no args provided — infer the requirement context from the current conversation and repository)'

phase('Research')
log('Scanning existing conventions before drafting...')

// Existing project: learn the stack/layout/test conventions so the spec doesn't fight reality.
// Greenfield: Explore reports "no conventions" and the draft stage proceeds anyway.
const conventions = await agent(
  `Scan this repository for existing conventions a new spec must respect: tech stack and versions, ` +
  `directory layout, build/test/lint commands, code style, and testing setup. ` +
  `If this is an empty or greenfield project with no relevant conventions, say so explicitly. ` +
  `Return a concise digest, not file dumps.`,
  { label: 'scan:conventions', phase: 'Research', agentType: 'Explore' },
)

// Draft each angle, then judge it the moment it finishes — no barrier between angles.
const judged = await pipeline(
  ANGLES,
  (angle) => agent(
    `Draft a complete spec from the "${angle.key}" angle (${angle.brief}).\n\n` +
    `Requirement context:\n${ctx}\n\n` +
    `Existing conventions to respect:\n${conventions}\n\n` +
    `Cover all six core areas (objective, commands, project structure, code style, testing strategy, ` +
    `boundaries) plus success criteria. Surface your assumptions explicitly rather than silently filling gaps.`,
    { label: `draft:${angle.key}`, phase: 'Research', schema: SPEC_SCHEMA },
  ),
  (draft, angle) => agent(
    `Judge this "${angle.key}" spec draft. Score completeness, testability, and boundary clarity (1-5 each), ` +
    `and list strengths, weaknesses, and risks. Be skeptical — reward concrete, testable success criteria ` +
    `and penalize vague boundaries.\n\nDraft:\n${JSON.stringify(draft)}`,
    { label: `judge:${angle.key}`, phase: 'Judge', schema: VERDICT_SCHEMA },
  ).then((verdict) => ({ angle: angle.key, draft, verdict })),
)

const ranked = judged
  .filter(Boolean)
  .map((j) => ({ ...j, score: j.verdict.completeness + j.verdict.testability + j.verdict.boundaryClarity }))
  .sort((a, b) => b.score - a.score)

log(`Drafted and judged ${ranked.length} angles. Synthesizing best recommendation...`)

phase('Synthesize')
// Use the highest-scoring draft as the spine, graft in the best ideas from the others.
const recommendation = await agent(
  `Synthesize one best-recommendation spec from these judged drafts. Use the highest-scoring draft as the ` +
  `spine and graft in the strongest ideas from the others. Keep success criteria specific and testable, ` +
  `and keep assumptions and open questions explicit for the human to confirm.\n\n` +
  `Judged drafts (highest score first):\n${JSON.stringify(ranked)}`,
  { label: 'synthesize:recommendation', phase: 'Synthesize', schema: SPEC_SCHEMA },
)

// Returned to the main session: the recommended spec plus a per-angle trade-off comparison.
// The main agent presents this, the human confirms or edits, then it is saved as SPEC.md.
return {
  recommendation,
  comparison: ranked.map((r) => ({ angle: r.angle, score: r.score, verdict: r.verdict })),
}
