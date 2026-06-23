# MSH Monorepo — Out-of-Date Analysis Report

> Generated 2026-06-20 by a parallel 4-agent audit (dependencies · documentation · toolchain/config · code patterns) over the `msh` monorepo at `/home/milos/code/msh` (12 npm workspaces + root).

## TL;DR

The repo is **in good shape structurally** — consistent ESM/TS setup across packages, no TODO/FIXME noise, no dead references from the recent v2.0.0 restructure, Babel fully purged. The out-of-date problems cluster in a few spots:

1. **`CLAUDE.md` tech-stack section is wrong on 4 versions** (TS, Node, npm, Vitest) — highest-visibility doc rot.
2. **`cli` builds/tests against an old internal dep** — `@beecode/msh-env ^1.2.0` while the local `env` workspace is `2.0.0`.
3. **`cli` ships deprecated prod dependencies** (`request`, `request-promise-native`, `mz`).
4. **`app-boot` is the odd package out** — missing `ignoreDeprecations: "6.0"` (TS 6 build risk), divergent `engines`, and a README importing a **non-existent package** (`@beecode/msh-node-log`).
5. **Minor cruft** — `console.log('test')` in `orm`'s published entry, a `"fallowing"` typo in `env` error messages, stale `istanbul ignore`, copy-paste README descriptions, inaccurate "WIP" labels.

**Severity totals:** 7 high · 12 medium · 13 low.

---

## Methodology

- **Dependencies:** live `npm outdated --json` + `npm view <pkg>@latest` / `deprecated` at repo root; all 12 `package.json` files read and cross-checked. **No static estimates** — all version data is live.
- **Docs / toolchain / code:** direct file reads across all `packages/*` `package.json`, `tsconfig.json`, `eslint.config.js`, READMEs, `resource/doc/**`, plus repo-wide `rg` sweeps for `babel`, `jest`, `require(`, `TODO/FIXME/@deprecated`, missing `.js` extensions.
- **Out of scope (intentionally):** the in-progress `env` refactor on the `refactore` branch (`MSH_ENV_WRAPPER_PLAN.md`, `env-resolver*.ts`) was checked for consistency only, not audited for bugs.

---

## 🔴 High-severity findings

| # | Area | Where | Issue | Fix |
|---|------|-------|-------|-----|
| H1 | Docs | `CLAUDE.md` → Tech Stack | TypeScript stated as `5.7.3+`; root pins `^6.0.3` | → `TypeScript 6.x` |
| H2 | Docs | `CLAUDE.md` → Tech Stack | Node stated as `22.22.1+`; `engines.node` is `>=20` (`.nvmrc` pins `v22.22.1`) | align the doc with `engines`/`.nvmrc` |
| H3 | Docs | `CLAUDE.md` → Tech Stack | npm stated as `10.9.2+`; `engines.npm` is `>=10` | align with `engines` |
| H4 | Docs | `CLAUDE.md` → Tech Stack | Vitest stated as `3.0.9+`; every package pins `^4.1.8` | → `Vitest 4.x` |
| H5 | Docs | `packages/app-boot/README.md` (L68) | Example imports `@beecode/msh-node-log` — package **does not exist** (it's the deprecated predecessor of `msh-logger`) | replace with `@beecode/msh-logger` |
| H6 | Docs | `packages/cli/README.md` (L79) | `'.mas'` config filename — actual file is `.msh` (`cli/src/util/config.ts` → `dotenv.config({ path: './.msh' })`) | `.mas` → `.msh` |
| H7 | Toolchain | `packages/app-boot/tsconfig.json` | Missing `ignoreDeprecations: "6.0"` (every sibling has it). With TS 6.x + `experimentalDecorators`/`emitDecoratorMetadata`, the build is at risk of hard deprecation errors. | add `"ignoreDeprecations": "6.0"` |

> Also a **high-impact dependency** issue (severity high for correctness): `packages/cli/package.json` declares `@beecode/msh-env ^1.2.0`, but the local `env` workspace is now **`2.0.0`**. npm resolves cli to the *published* `1.2.0`, so cli builds and tests against the **old** env API while the rest of the monorepo uses 2.0.0. → bump cli's range to `^2.0.0`.

---

## 🟡 Medium-severity findings

### Dependencies

| Issue | Where | Detail |
|-------|-------|--------|
| Deprecated prod deps | `packages/cli/package.json` | `request ^2.88.2` and `request-promise-native ^1.0.9` officially deprecated since 2020; `mz ^2.7.0` unmaintained (last release 2018) → migrate to a maintained client / native `fs.promises`+`util.promisify` |
| js-yaml major lag | `packages/test-contractor` | `^4.2.0` → `5.0.0` (breaking) |
| eslint major lag | `packages/config` | `eslint ^9.0.0` → `10.5.0`; `@eslint/js ^9.0.0` → `10.0.1` |
| `@types/node` major lag | 11 packages | `^25.9.3` → `26.0.0` |
| `@types/minimatch` stale | `packages/base-frame` | `^6.0.0` while runtime `minimatch` is `^10.2.5` (v10 ships its own types — `@types/minimatch` may be redundant) |

### Toolchain / config

| Issue | Where | Detail |
|-------|-------|--------|
| ESLint globals wrong | `packages/config/src/eslint-config.mjs:29` | Uses `globals.browser` for a **Node** monorepo → should be `globals.node` |
| `types: []` blocks `@types/node` | `packages/node-session/tsconfig.json` | empty `types` array suppresses auto-inclusion of installed `@types/node`; siblings use `["node"]` or omit it |
| Engines diverge | `packages/app-boot/package.json` | `node >=20.8.1 npm >=10.1.0` vs root `>=20`/`>=10`; enforced via `.npmrc: engine-strict=true` |
| Prettier width vs docs | `packages/config/src/prettier-config.js` | `printWidth: 120` but `CLAUDE.md` says "max line 130" — pick one |
| Stray nested-git dir | `packages/base-temp/` | Has its own `.git` + remote `msh-base-temp.git`, referenced in `.msh` PROJECTS and `msh.code-workspace`, but **not** a workspace and has no `package.json`. It is intentional scratch (root `.gitignore` ignores `/base-temp`, `INIT_SETUP.md` documents the clone) — but it shouldn't appear in workspace tooling. Document it as dev-only or remove from `.msh`/code-workspace. |

### Documentation

| Issue | Where | Detail |
|-------|-------|--------|
| Copy-paste wrong descriptions | `packages/orm/README.md` ("node environment"), `packages/util/README.md` ("node error"), `packages/node-session/README.md` ("node error") | each carries another package's description |
| Stale `/dist` import paths | `packages/node-session/README.md` (L43-46), `packages/app-boot/README.md` (L71) | deep `/dist`/`/lib` paths predate the subpath-export pattern |
| Inaccurate "WIP" labels | root `README.md` (L36-40) | `test-contractor` (v0.4.2, **50 src files**, full YAML contract DSL) and `base-frame` (v0.6.2, **28 src files**) are substantial, not WIP |
| `base-temp` clone outside workspaces | `INIT_SETUP.md` (L13-14) | instructs cloning `msh-base-temp` into top-level `base-temp`, which isn't a workspace entry |

### Code

| Issue | Where | Detail |
|-------|-------|--------|
| Debug log in published entry | `packages/orm/src/index.ts:1` | `console.log('test')` ships to consumers via `dist/index.js` — remove |
| Typo in error message | `packages/env/src/business/component/env/type.ts:91` | `"the fallowing values:"` → `following`; mirrored in `type.test.ts:210,212,313,315` |

---

## 🟢 Low-severity findings

| Issue | Where | Detail |
|-------|-------|--------|
| `istanbul ignore file` leftover | `packages/app-boot/src/index.ts:1` | Istanbul pragma in a Vitest repo (no `nyc`) — remove |
| `console.log(err)` in entry | `packages/base-frame/src/index.ts:35` | route through `logger().error` like surrounding lines |
| orm is a stub | `packages/orm/` | only `index.ts` + test, empty `description`, v0.0.1 — mark WIP/gate it |
| entity thin + empty description | `packages/entity/package.json:4` | re-exports only; label WIP |
| Stale jest ignore | all `eslint.config.js` | every config ignores `jest.config*.ts` but jest was removed |
| `ignores` drift | per-package `eslint.config.js` | `error` uniquely adds `.*.cjs`; `config` omits `dist`/`packages`/`typedoc.json`/`release.config.cjs` |
| Dead `tsc-esm-alias` script | `packages/cli`, `packages/base-frame` | defined but `build` never calls it; `tsc-alias ^1.8.17` root devDep otherwise unused |
| `baseUrl` cosmetic drift | `packages/base-frame/tsconfig.json` | `"."` vs `"./"` in 10 siblings |
| `docker-compose.yml` `version` key | L1 | `version: '3.5'` obsolete under Compose v2 (warning) |
| codecov placeholder | `packages/orm/README.md:2` | `token=<// TODO add token>` in badge URL |
| cli help wording | `packages/cli/README.md:110` | "in all containers" → projects are dirs, not containers |
| Tests-path convention self-contradiction | `CLAUDE.md` → Code Conventions | says `src/__tests__/` *and* `*.test.ts` co-located — reconcile (repo uses co-located `*.test.ts`) |
| `@types/handlebars`/`@types/minimatch` > latest | `packages/base-frame` | latest published is lower than the declared range (harmless; types rolled back) |

---

## ✅ Checked and found current (no action)

- **ESM hygiene:** 100% of `#src/...` imports carry `.js` extensions; **zero** CommonJS `require()` in source.
- **No stale references** from the three recent restructures (`mshenv → msh-env` move, v2.0.0 restructure, babel removal) — verified by repo-wide grep incl. docs. The only babel mention is historical prose in `resource/todo/SIMPLIFY_SOLUTION_PROPOSAL.md`.
- **No `TODO`/`FIXME`/`HACK`/`XXX`/`@deprecated` markers** anywhere in `src` or docs.
- **`env` refactor is internally consistent** — `index.ts` exports (`mshEnvResolver`, `MshEnvResolverError`, `MshEnvResolverFailure`, …) all resolve to real files; old `.required()` terminator model already removed; no orphaned exports.
- **Shared dev deps are uniform** across all 12 packages: `typescript ^6.0.3`, `vitest ^4.1.8`, `@vitest/coverage-v8 ^4.1.8`, `prettier ^3.8.4`, `@commitlint/* ^21.0.2`, `husky ^9.1.7`, `lint-staged ^17.0.7`, `@types/node ^25.9.3`.
- **Documented npm scripts are all valid** — no broken/renamed commands in READMEs/CLAUDE.md/COMMIT_STRATEGY.md.
- **`packages/env` README + strategy docs are accurate** and match the current API surface.
- **`base-temp` is intentional** (gitignored sibling template clone) — leave on disk; just don't let it leak into workspace tooling.

---

## Suggested fix order

A cheap, high-value pass that knocks out most of the visible rot:

1. **`CLAUDE.md` Tech Stack** — correct TS/Node/npm/Vitest (H1–H4). 2-minute fix, biggest visibility.
2. **cli README** — `.mas` → `.msh` (H6); replace `@beecode/msh-node-log` everywhere it appears (H5 lives in app-boot but grep for the phantom package repo-wide).
3. **app-boot `tsconfig.json`** — add `ignoreDeprecations: "6.0"` (H7).
4. **cli `package.json`** — bump `@beecode/msh-env` to `^2.0.0`; plan migration off `request`/`request-promise-native`/`mz`.
5. **eslint shared config** — `globals.browser` → `globals.node` (med); removes a class of false-positive/no-op linting for server code.
6. **Quick cleanups** — remove `console.log('test')` from `orm/src/index.ts` (med), fix `"fallowing"` typo in `env` (med), drop stale `istanbul ignore`, reconcile prettier 120 vs docs-130.
7. **Docs accuracy sweep** — fix 3 copy-paste descriptions, update WIP labels for `test-contractor`/`base-frame`, refresh stale `/dist` import examples.

Items 1, 2, 5, 6 are mechanical and safe to batch. Items 3, 4, 7 benefit from a quick validation build/test.

---

*Source: 4 parallel sub-agents (general-purpose) run over the full repo. Dependency data is live from npm; all other findings cite exact files/lines.*
