# Commit Strategy — Semantic Release (Angular Preset)

This project uses [semantic-release](https://semantic-release.gitbook.io/) with the **Angular commit convention** preset to automate versioning, changelog generation, and GitHub releases.

---

## How It Works

Every commit message is analyzed by `@semantic-release/commit-analyzer`. Based on the commit **type** (and optional **breaking change** marker), the package version is bumped automatically:

| Version Bump | Trigger | Example |
|---|---|---|
| **MAJOR** (x.0.0) | `type!:` or `BREAKING CHANGE` in footer | `refactor!: rewrite public API` |
| **MINOR** (0.x.0) | `feat:` | `feat: add Pino logger strategy` |
| **PATCH** (0.0.x) | `fix:` | `fix: correct import path in mock` |
| **None** | `chore:`, `docs:`, `test:`, `build:`, `ci:`, `style:`, `perf:`, `refactor:` (without `!`) | `chore: update dependencies` |

---

## Commit Message Format

```
<type>(<scope>): <short summary>
                  ↑ no period, imperative mood, lowercase

[optional body — explain WHAT and WHY, not HOW]

[optional footer — BREAKING CHANGE: <description>]
```

### Rules

- **Subject line**: max 100 characters, imperative mood (`add`, `fix`, `update` — not `added`, `fixing`, `updated`)
- **No period** at the end of the subject
- **Lowercase** subject (unless referencing a proper noun like `Pino`, `NewRelic`)
- **Scope** is optional but encouraged: `feat(logger):`, `fix(console):`, `refactor(api):`
- **Body** is separated from the subject by a blank line
- **Footer** is separated from the body by a blank line

---

## Commit Types Reference

### Version-Bumping Types

#### `feat:` → MINOR bump

A new feature for the package consumer.

```
feat: add Pino logger strategy implementation
feat(console): accept params like console.log()
feat: meta can be string or object
```

#### `fix:` → PATCH bump

A bug fix or correction that affects the package consumer.

```
fix: correct import path in log-strategy-mock
fix: update package dependencies to latest versions
fix(console): use console info/warn/error/log
```

#### `BREAKING CHANGE` → MAJOR bump

Any commit type can trigger a major bump by including a breaking change. Two formats are accepted:

**Option A — Bang after type (`type!:`):**
```
refactor!: es modules and commonjs build

BREAKING CHANGE: changed file structure
```

**Option B — Footer only (no bang):**
```
feat: added console log strategy

BREAKING CHANGE: remove index to strategy implementations
add console log strategy (simple, newRelicJson)
update package json and audit fix
```

> Both `refactor!:` and `feat:` with a `BREAKING CHANGE` footer produce the same MAJOR bump.

### Non-Version-Bumping Types

These types are recognized but **do not** trigger a version bump:

| Type | Purpose | Example |
|---|---|---|
| `chore:` | Maintenance, tooling, CI, dependency updates | `chore: update dependencies` |
| `docs:` | Documentation changes | `docs: fix diagram gen script` |
| `test:` | Adding or updating tests | `test: add console log strategies e2e tests` |
| `build:` | Build system or external dependencies | `build: configure dist output as entry point` |
| `ci:` | CI/CD configuration | `ci: update semaphore pipeline` |
| `style:` | Formatting, whitespace (no code change) | `style: fix indentation` |
| `perf:` | Performance improvement | `perf: reduce object allocation in hot path` |
| `refactor:` | Code restructuring (no behavior change, no `!`) | `refactor: consolidate log fields into metadata` |

---

## Real Examples from This Project

### MAJOR (1.0.0) — Breaking Change
```
refactor!: es modules and commonjs build (#3)

BREAKING CHANGE: changed file structure
```
→ Bumped `0.2.1` → `1.0.0`

### MAJOR (2.0.0) — Feature with Breaking Change
```
feat: added console log strategy

BREAKING CHANGE: remove index to strategy implementations
```
→ Bumped `1.1.6` → `2.0.0`

### MINOR (1.2.0) — New Feature
```
feat: add Pino logger strategy implementation (#81)
```
→ Bumped `1.1.3` → `1.2.0`

### PATCH (1.2.1) — Bug Fix
```
fix: update packages and tests
```
→ Bumped `1.2.0` → `1.2.1`

### No Bump — Maintenance
```
chore: remove dist and lib from release assets
docs: fix diagram gen script
test: add console log strategies e2e tests
```

---

## Quick Decision Table

| I am... | Commit type | Version effect |
|---|---|---|
| Adding a new feature | `feat:` | +0.1.0 |
| Fixing a bug | `fix:` | +0.0.1 |
| Changing a public API incompatibly | `feat!:` or `fix!:` or `refactor!:` | +1.0.0 |
| Adding `BREAKING CHANGE` footer | any type | +1.0.0 |
| Updating docs | `docs:` | none |
| Updating tests | `test:` | none |
| Updating build/CI | `build:` / `ci:` | none |
| Updating dependencies | `chore:` | none |
| Refactoring internals | `refactor:` | none |

---

## Tools & Enforcement

| Tool | Role |
|---|---|
| **commitlint** (`@commitlint/config-conventional`) | Rejects commits that don't follow the format |
| **commitizen** (`cz-conventional-changelog`) | Interactive prompt (`git cz`) to format commits correctly |
| **husky** + **lint-staged** | Pre-commit hooks for linting and message validation |
| **semantic-release** | Reads commits, bumps version, generates CHANGELOG, publishes GitHub release |

### Dry-Run Check

Before pushing, verify what version would be released:

```bash
npm run npm-semantic-release-check
```

This runs `semantic-release --dry-run --no-ci` and reports the next version without publishing.
