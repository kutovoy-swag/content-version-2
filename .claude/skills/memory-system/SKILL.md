---
name: memory-system
description: Deploy and maintain a 3-layer memory system for any Claude Code project — so context survives between sessions. Use with $ARGUMENTS (setup | check | cleanup).
---

# Memory System — 3-Layer Agent Memory

A complete memory system for OpenClaw agents. Without memory, every session starts from zero. With it, the agent remembers decisions, mistakes, preferences, and project context.

**Core principle:** LLMs forget everything between sessions. Memory lives in files that auto-load into every session.

---

## Architecture: 3 Layers

```
┌──────────────────────────────────────────────┐
│  Layer 1: MEMORY.md (instant memory)         │  ← Auto-loaded EVERY session
│  Always visible via Project Context          │
├──────────────────────────────────────────────┤
│  Layer 2: memory/*.md (daily journals)       │  ← Found via memory_search
│  Daily entries + topic files                 │
│  Semantic search across all files            │
├──────────────────────────────────────────────┤
│  Layer 3: QMD (long-term memory)             │  ← Automatic semantic search
│  Indexes ALL markdown files in workspace     │
│  Finds relevant context by meaning           │
└──────────────────────────────────────────────┘
```

### Layer 1: MEMORY.md
The ONLY file guaranteed to be seen every session. Auto-loaded into Project Context. Agent sees it without doing anything.

**What goes here:** Owner info, permanent rules, active projects, recent decisions, mistakes to avoid.

**Key rule:** Most important info in the first 10 lines. LLMs pay more attention to the top.

### Layer 2: memory/*.md
Daily journals (`memory/YYYY-MM-DD.md`). Agent writes work results, decisions, context here. Accessed via `memory_search` — semantic search across all files.

**Why separate:** MEMORY.md has limited space. Everything that doesn't fit goes into journals. When the agent needs old context, it searches by meaning.

### Layer 3: QMD
Automatically indexes all markdown files in workspace. When the agent calls `memory_search("topic")`, QMD finds relevant fragments by meaning.

- Provider: OpenAI `text-embedding-3-small`
- Indexes automatically
- Works passively — agent just searches

---

## Mode 1: Memory Setup

**Triggers:** `настрой память`, `memory setup`

### Steps:

1. **Create workspace structure:**

```
workspace/
├── MEMORY.md              — long-term memory (auto-loaded)
├── SOUL.md                — identity & rules (owner-editable only)
├── HEARTBEAT.md           — maintenance rules
├── memory/                — daily journals
│   └── YYYY-MM-DD.md
└── learning/
    ├── corrections.md     — mistakes in RULE format
    └── anti-patterns.md   — what doesn't work
```

2. **Create MEMORY.md** from template in `references/memory-structure.md`

3. **Add memory_search to SOUL.md** (append, don't rewrite):
```markdown
## Memory Recall
Before answering questions about prior work, decisions, or preferences: run `memory_search` first. Check memory/*.md for relevant context.
```

4. **Enable Memory Flush** in openclaw.json (if not already):
```json
{
  "agents": {
    "defaults": {
      "compaction": {
        "memoryFlush": {
          "enabled": true,
          "softThresholdTokens": 4000
        }
      }
    }
  }
}
```

Memory Flush automatically prompts the agent to save important context when the session approaches compaction. Set `softThresholdTokens` to trigger early enough (4000 recommended).

5. **Enable QMD** in openclaw.json:
```json
{
  "memorySearch": {
    "enabled": true,
    "provider": "openai",
    "model": "text-embedding-3-small"
  }
}
```

6. **Create today's journal** `memory/YYYY-MM-DD.md` with basic template.

7. **Confirm:** show what was created, what already existed, what was added.

---

## Mode 2: Memory Check

**Triggers:** `проверь память`, `memory check`

### Steps:

#### 1. Check daily journals
- Check `memory/YYYY-MM-DD.md` for last 3 days
- Exist? Not empty?
- ✅ Present and filled → OK
- ⚠️ Missing or empty → warn

#### 2. Check MEMORY.md
- When was it last updated?
- If >7 days → ⚠️ "MEMORY.md is stale"
- Are key sections filled?

#### 3. Check learning/
- Does `corrections.md` have entries?
- Does `anti-patterns.md` have entries?
- Empty files = agent isn't learning

#### 4. Consolidate
- Scan `memory/*.md` for last 7 days
- Collect key decisions, insights, facts
- Update MEMORY.md — add new, remove duplicates
- Update "Recent decisions" section

#### 5. Cleanup
- Find files in `memory/` older than 30 days
- Suggest archiving to `memory/archive/`
- Don't delete without confirmation

#### 6. Report
```
🧠 Memory Health
━━━━━━━━━━━━━━━━
📁 Daily journals: X files
📅 Last entry: YYYY-MM-DD
📋 MEMORY.md: current / stale (X days)
📚 Corrections: X entries
🧹 To archive: X files (>30 days)
🔍 memory_search: enabled / not configured
💾 Memory Flush: enabled / not configured

Health Score: X/10
```

**Score:**
- 10 — everything perfect, logs fresh, MEMORY current
- 7-9 — minor gaps (missed day, empty learning)
- 4-6 — problems (MEMORY stale, no logs 3+ days)
- 1-3 — critical (memory not working)

---

## Mode 3: Memory Cleanup

**Triggers:** `почисти память`, `memory cleanup`

Ревизия и очистка памяти от мусора. Удаляет устаревшее, дубликаты, мёртвые записи.

### Steps:

#### 1. Ревизия MEMORY.md
Прочитать MEMORY.md целиком. Для каждой записи спросить:
- **Актуально?** Если решение заменено новым → удалить старое
- **Дубликат?** Если факт повторяется → оставить одну копию
- **"НЕ использовать"?** Если запись содержит "НЕ использовать", "устарело", "отменено" → удалить целиком
- **Конкретно?** Если запись расплывчатая и бесполезна → удалить

#### 2. Ревизия learning/
- `corrections.md` — удалить правки старше 30 дней, которые уже усвоены (повторяющиеся ошибки = не усвоены, оставить)
- `approved-patterns.md` — удалить паттерны которые стали очевидными и не нужны как напоминание
- `rejected-patterns.md` — удалить записи которые больше не релевантны (например, для удалённого формата контента)
- Правки повторяющиеся 3+ раз → перенести как правило в SOUL.md (секция Learned Patterns), удалить из learning/

#### 3. Ревизия memory/*.md
- Файлы старше 30 дней → предложить архивирование в `memory/archive/`
- Пустые файлы → удалить
- Файлы с единственной записью "нет активности" → удалить

#### 4. Лимиты SOUL.md
- Секция "Learned Patterns" — максимум 15-20 правил
- Если добавляется новое правило, а лимит превышен → вытеснить наименее важное

#### 5. Отчёт

```
🧹 Memory Cleanup
━━━━━━━━━━━━━━━━━
📋 MEMORY.md: удалено X записей, осталось Y
📚 learning/: удалено X записей, перенесено Y правил в SOUL.md
📁 memory/: удалено X пустых, предложено архивировать Y файлов
📏 SOUL.md Learned Patterns: X/20 правил

Принцип: нет записи = нет токенов = нет путаницы.
```

**Критерий:** после очистки MEMORY.md должен помещаться в ~2000 токенов. Если больше — продолжить чистку.

---

## What Works and What Doesn't

### ✅ Works: Auto-loaded files (MEMORY.md)
Agent sees them every session without effort. 100% hit rate.

### ✅ Works: Semantic search (memory_search + QMD)
Agent finds old context by meaning. Passive, low-effort.

### ✅ Works: Memory Flush (compaction prompt)
Automatically saves context before session compaction. Safety net.

### ❌ Doesn't work: Databases (SQLite, etc.)
LLM won't query a database on its own. It needs to: decide something is missing → write SQL → execute → interpret. 4 steps it will never take unprompted. Tested at scale — 5 out of 10 agents had zero DB queries in a week.

### ❌ Doesn't work: Task queues in files
Files that require agents to actively check them get ignored. Use cron jobs or Notion instead.

### ❌ Doesn't work: Regex extraction
Parsing session logs with regex produces garbage. LLM-based extraction (reading logs with a model) works 10x better.

---

## Memory Flush Format

When session nears compaction, the agent saves context in this format:

```markdown
## Decisions
- [DECISION] what was decided → outcome

## Active Tasks
- [TASK] name | status: done/in-progress/blocked | next: concrete step

## Corrections
- [CORRECTION] what went wrong | [CORRECT] how to do it right | [RULE] [category] rule

## Context for Next Session
- key fact the future self MUST know
```

Categories for RULE: `style | format | content | platform | tone | process`

---

## Corrections Format (learning/corrections.md)

```markdown
CORRECTION: what happened
REASON: why it's wrong
CORRECT: how to do it right
RULE: [category] one-line rule for the future
```

This format makes mistakes searchable and actionable. The agent reads corrections.md before repeating work.

---

## MEMORY.md vs SOUL.md

| | SOUL.md | MEMORY.md |
|---|---|---|
| What | Identity, role, behavior rules | Facts, decisions, context |
| Who edits | Only the owner | Agent + extraction pipeline |
| Changes | Rarely | Constantly |
| Analogy | DNA | Working memory |

**Rule:** SOUL.md is read-only for agents. MEMORY.md is read-write.

---

## References

- `references/memory-structure.md` — file templates
- `references/memory-rules.md` — memory rules and lifecycle
