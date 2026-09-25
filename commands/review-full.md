---
description: Full project review across frontend, backend, and bash
---

# /review-full

Orchestrator for full project review across all three layers.

## Strategy

Big projects must NOT be reviewed in one pass — context fills up and findings degrade. Determine size first.

## Step 1 — sizing

Count source files (exclude `node_modules`, `dist`, `build`, `coverage`, `.next`, `.git`, generated dirs):

```bash
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.mjs" -o -name "*.sh" \) \
  -not -path "*/node_modules/*" -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/coverage/*" -not -path "*/.next/*" -not -path "*/.git/*" | wc -l
```

Also note: monorepo? multiple workspaces?

## Step 2 — branch on size

**If > 200 source files OR a monorepo with multiple workspaces:**

Stop. Do not start the review. Tell the user:

> Проект большой (N файлов / M workspaces). Запусти отдельными сессиями в порядке:
> 1. `/review-frontend`
> 2. `/review-backend`
> 3. `/review-bash`
>
> После каждой можно делать паузу, фиксить критичное, и идти дальше — так точность выше, чем одной сессией.

Then exit.

**If ≤ 200 source files and single workspace:**

Run all three reviews in this session, in order, with clear section headers between them:

```
# Frontend
…/review-frontend output…

# Backend
…/review-backend output…

# Bash
…/review-bash output…
```

After all three, write a **cross-cutting summary** (3 sentences max):
- Which layer is in worst shape.
- What theme repeats across layers (e.g. inconsistent error handling, missing input validation everywhere).
- The single highest-leverage change.

Then ask: «Что чинить первым?»
