---
name: game-design-document
displayName: Game Design Document
description: Use when creating, auditing, summarizing, restructuring, or updating a game design document, design bible, `GAME_DESIGN_DOCUMENT.md`, `GDD.md`, or related `design/` documentation for a game. Use for capturing concept, pillars, scope, mechanics, feel, world, visual/audio/UI direction, assets, testing plans, or design questions. Do not use for pure implementation, debugging, refactoring, code-focused feature work, or playtesting.
version: 1.0.0
metadata:
  category: Game Development
  tags:
    - game
    - design
    - documentation
    - gdd
---

# Game Design Document

Use this skill to create and maintain concise, living game design documents that guide real work.

## Workflow

1. Locate the living GDD before creating a new one.
   - Prefer `GAME_DESIGN_DOCUMENT.md`, `game_design_document.md`, `game-design-document.md`, `GDD.md`, or `gdd.md`.
   - Check the same filenames under `design/`.
   - Create `GAME_DESIGN_DOCUMENT.md` only when no candidate exists or the user explicitly requests a new document.
2. Read the document efficiently.
   - Use `listSymbols` to inspect Markdown headings when symbol tools are available.
   - Use `readSymbol` to read only the relevant heading body after initial orientation.
   - Use full `readFile` only for initial orientation, small files, or unsupported formats.
   - Search for mechanics, controls, assets, scope, pillars, constraints, risks, and open questions.
3. Classify the GDD task.
   - For new documents, use [the GDD template](references/gdd-template.md).
   - For audits, restructuring, or section expansion, use [the GDD structure reference](references/gdd-structure.md).
   - For mechanics, player feel, or accessibility refinement, use [the design lenses](references/design-lenses.md).
4. Capture the current design intent.
   - Extract the concept, target player, platform, core loop, design pillars, scope, constraints, and non-goals.
   - Ask targeted questions only when missing intent blocks useful progress.
   - Mark unresolved design choices as `TBD` or `Open Question`; do not invent commitments.
5. Update the GDD as a living document.
   - Keep edits concise, searchable, and easy to update.
   - Preserve existing headings and terminology unless restructuring is requested or clearly needed.
   - Use bullets, tables, and checklists when they reduce ambiguity.
   - Add the smallest useful section instead of filling every possible template field.
6. Separate design documentation from implementation tracking.
   - Capture implementation notes only when they clarify design status, acceptance criteria, or validation needs.
   - Keep code, asset, and runtime validation details brief unless the user requested implementation planning.
7. Validate consistency.
   - Check that mechanics, goals, controls, UI, assets, and testing plans do not contradict each other.
   - Verify relative links, asset paths, and referenced project files when practical.
   - Remove stale or duplicated sections when restructuring.
8. Summarize the result.
   - State which GDD file changed.
   - List the sections created or updated.
   - Call out new decisions, open questions, and any design gaps that still affect progress.
