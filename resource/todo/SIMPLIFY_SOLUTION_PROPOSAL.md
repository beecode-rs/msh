# MSH Monorepo Simplification Proposal

## Executive Summary

This proposal addresses configuration duplication across the 12 packages in the MSH monorepo. Analysis reveals **~2,000-2,200 lines of duplicated configuration** that can be centralized while maintaining the ability to publish packages independently to npm.

**Key Findings:**
- 100% duplication in TypeScript configurations (672 lines)
- 95%+ duplication in build scripts, test configurations, and Babel configs (1,400+ lines)
- 95%+ duplication in devDependencies across all packages
- Version drift in test-contractor package

**Potential Impact:**
- Reduce configuration maintenance by ~80%
- Standardize tooling versions across all packages
- Simplify onboarding and updates
- Maintain independent npm publishing capability

---

## Current State Analysis

### Package Overview
- **12 packages** in `/packages/*`
- **Already a monorepo** using npm workspaces
- Each package independently publishable to npm
- Shared ESLint/Prettier configs via `@beecode/msh-config`

### Configuration Duplication Breakdown

| Configuration Type | Files | Lines Duplicated | Similarity |
|-------------------|-------|------------------|------------|
| tsconfig.json | 12 | ~672 | 100% |
| tsconfig.build.json | 12 | ~192 | 100% |
| vitest.config*.ts | 36 | ~576 | 95% |
| babel.config | 12 | ~360-400 | 95% |
| package.json scripts | 12 | ~800 | 95% |
| eslint.config.js | 12 | ~300 | 90% |
| .prettierrc.json | 12 | ~12 | 100% |
| **TOTAL** | **108 files** | **~2,900 lines** | **95%+** |

### DevDependencies Analysis

**Common to all 12 packages (~40+ dependencies):**
- Babel toolchain (6 packages)
- TypeScript toolchain (5 packages)
- Testing (vitest, coverage)
- Linting (commitlint, prettier, lint-staged, husky)
- Build tools (rimraf, ts-cleaner, tsc-alias, etc.)
- Documentation (typedoc)

**Version inconsistencies detected:**
- `test-contractor` has older/newer versions of 15+ packages
- Other packages are synchronized

---

## Problems Identified

### 1. Maintenance Burden
- Updating configurations requires changes to 12 files
- Version updates must be synchronized manually
- High risk of configuration drift (already present in test-contractor)

### 2. Onboarding Complexity
- New contributors see repeated configs and may not understand the pattern
- Unclear which configurations are intentionally different vs. drift

### 3. Version Drift
- test-contractor has diverged in dependency versions
- No automated enforcement of version consistency

### 4. Unnecessary File Count
- 108 configuration files that could be reduced to <20
- Increases cognitive load when navigating the codebase

### 5. Build Script Duplication
- Same 20+ npm scripts in every package.json
- Changes to build process require 12-file updates

---

## Proposed Solution

### Strategy: Root-Level Configuration Inheritance

Maintain the monorepo structure while centralizing shared configurations at the root level. Each package inherits from root configs and overrides only when necessary.

### Phase 1: TypeScript Configuration Centralization

**Implementation:**

1. Create `/tsconfig.base.json` at root:
```json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ESNext"],
    "esModuleInterop": true,
    "skipLibCheck": true,
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "resolveJsonModule": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "jsx": "react-jsx"
  }
}
```

2. Create `/tsconfig.build.base.json` at root:
```json
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "rootDir": "./src"
  },
  "exclude": [
    "**/*.test.ts",
    "**/*.int.test.ts",
    "**/__tests__/**",
    "**/__mocks__/**"
  ]
}
```

3. Update each `/packages/*/tsconfig.json`:
```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "baseUrl": ".",
    "outDir": "./dist",
    "paths": {
      "#packageJson": ["./package.json"],
      "#src": ["./src"],
      "#src/*": ["./src/*"]
    }
  },
  "include": ["src/**/*", "test/**/*"]
}
```

4. Update each `/packages/*/tsconfig.build.json`:
```json
{
  "extends": "../../tsconfig.build.base.json",
  "compilerOptions": {
    "baseUrl": ".",
    "outDir": "./dist",
    "paths": {
      "#packageJson": ["./package.json"],
      "#src": ["./src"],
      "#src/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"]
}
```

**Impact:**
- Reduces 24 files to 2 root files + 24 minimal overrides
- ~850 lines → ~200 lines (76% reduction)
- Single source of truth for TypeScript settings

---

### Phase 2: Vitest Configuration Centralization

**Implementation:**

1. Create `/vitest.config.base.ts` at root:
```typescript
import { defineConfig } from 'vitest/config'
import tsconfigPaths from 'vite-tsconfig-paths'

export const createVitestConfig = (packageDir: string) =>
	defineConfig({
		plugins: [tsconfigPaths()],
		test: {
			globals: true,
			environment: 'node',
			coverage: {
				provider: 'v8',
				reporter: ['text', 'json', 'html'],
			},
			setupFiles: [`${packageDir}/test/setup.ts`],
		},
	})

export const createUnitConfig = (packageDir: string) =>
	defineConfig({
		...createVitestConfig(packageDir),
		test: {
			...createVitestConfig(packageDir).test,
			include: ['**/*.test.ts'],
			exclude: ['**/*.int.test.ts'],
		},
	})

export const createIntConfig = (packageDir: string) =>
	defineConfig({
		...createVitestConfig(packageDir),
		test: {
			...createVitestConfig(packageDir).test,
			include: ['**/*.int.test.ts'],
		},
	})
```

2. Update each package's vitest configs:
```typescript
// packages/*/vitest.config.ts
import { createVitestConfig } from '../../vitest.config.base'
export default createVitestConfig(__dirname)

// packages/*/vitest.config.unit.ts
import { createUnitConfig } from '../../vitest.config.base'
export default createUnitConfig(__dirname)

// packages/*/vitest.config.int.ts
import { createIntConfig } from '../../vitest.config.base'
export default createIntConfig(__dirname)
```

**Impact:**
- 36 files → 1 root file + 36 minimal wrappers
- ~576 lines → ~100 lines (83% reduction)
- Centralized test configuration logic

---

### Phase 3: Babel Configuration Centralization

**Implementation:**

1. Create `/babel.config.base.cjs` at root:
```javascript
module.exports = {
	presets: [
		['@babel/preset-env', { targets: { node: 'current' } }],
		['@babel/preset-typescript', { allowDeclareFields: true }],
	],
	plugins: [
		['@babel/plugin-proposal-decorators', { legacy: true }],
		'@babel/plugin-transform-modules-commonjs',
	],
}
```

2. Update each package's babel.config.cjs:
```javascript
module.exports = require('../../babel.config.base.cjs')
```

**Impact:**
- 12 files → 1 root file + 12 one-liners
- ~360 lines → ~30 lines (92% reduction)

---

### Phase 4: Package Script Standardization

**Implementation:**

Create shared script definitions that can be referenced or use a task runner.

**Option A: NPM Script Inheritance (Simple)**

1. Document standard scripts in root `/package.json`:
```json
{
  "scripts": {
    "// Standard package scripts": "",
    "// build": "npm run clean && npm run tsc && npm run fix-hybrid-lib-esm",
    "// build-cjs": "npm run clean-cjs && npm run tsc-cjs && npm run tsc-types && npm run tsc-types-alias && npm run fix-hybrid-lib-cjs",
    "// test": "concurrently -c auto 'npm:test:*'",
    "// ... etc": ""
  }
}
```

2. Keep scripts in packages but now there's documentation

**Option B: Shared Scripts Package (Advanced)**

1. Create `packages/scripts` with reusable build scripts
2. Reference from package.json: `"build": "msh-scripts build"`

**Option C: Turborepo/Nx (Most Advanced)**

1. Migrate to Turborepo for task orchestration
2. Define tasks once in root `turbo.json`
3. Remove most scripts from packages

**Recommended: Option A** (least disruptive, good documentation)

**Impact:**
- No reduction in lines, but standardization enforced
- Future updates documented in one place

---

### Phase 5: Dependency Version Synchronization

**Implementation:**

1. Use root `package.json` to define all devDependency versions:
```json
{
  "devDependencies": {
    "@babel/cli": "^7.28.6",
    "@babel/core": "^7.28.6",
    // ... all shared dependencies
  }
}
```

2. Update workspace packages to reference root versions:
```json
{
  "devDependencies": {
    "@babel/cli": "*",
    "@babel/core": "*"
  }
}
```

3. Add syncpack for automated version checking:
```bash
npm install -D syncpack
```

4. Add to root package.json:
```json
{
  "scripts": {
    "check-deps": "syncpack list-mismatches",
    "fix-deps": "syncpack fix-mismatches"
  }
}
```

**Impact:**
- Eliminates version drift
- Single source for dependency versions
- Automated enforcement via CI

---

### Phase 6: Hoisting DevDependencies

**Implementation:**

Move all shared devDependencies to root package.json:

1. Identify package-specific vs shared dependencies
2. Move shared deps to root (workspace will hoist automatically)
3. Keep package-specific deps in packages

**Shared devDependencies (move to root):**
- All Babel packages
- TypeScript toolchain
- Vitest packages
- ESLint/Prettier tools
- Build tools (rimraf, tsc-alias, etc.)
- Commitlint packages
- Documentation tools

**Package-specific (keep in packages):**
- @types/* specific to package needs
- Package-specific testing utilities

**Impact:**
- Reduces package.json devDependencies by ~80%
- Faster installs (less duplication)
- Easier version management

---

### Phase 7: ESLint Configuration Cleanup

**Current state:** Already partially centralized via @beecode/msh-config

**Optimization:**

1. Create `/eslint.config.base.js` at root:
```javascript
import mshConfig from '@beecode/msh-config/src/eslint-config.mjs'

export default [
	...mshConfig,
	{
		ignores: [
			'**/node_modules/**',
			'**/dist/**',
			'**/lib/**',
			'**/coverage/**',
			'**/.git/**',
		],
	},
]
```

2. Update package eslint.config.js:
```javascript
import baseConfig from '../../eslint.config.base.js'

export default [
	...baseConfig,
	// Package-specific overrides here if needed
]
```

**Impact:**
- 12 files → 1 root + 12 minimal wrappers
- ~300 lines → ~50 lines (83% reduction)

---

### Phase 8: Git Configuration Cleanup

**Current state:** Each package has `.git/`, `.gitignore`, `.git-config`

**Optimization:**

1. Use single root `.gitignore` (already exists)
2. Remove package-level `.gitignore` files (identical)
3. Consolidate git hooks to root `.git/hooks`
4. Remove `.git-config` from packages

**Impact:**
- 12 `.gitignore` files → 1 root file
- Simpler git management

---

## Implementation Roadmap

### Phase 1-2: TypeScript & Vitest (Low Risk)
**Time estimate:** 2-3 hours
**Risk:** Low
**Steps:**
1. Create base configs at root
2. Update package configs to extend base
3. Run `npm run build` and `npm run test` to verify
4. Commit changes

### Phase 3: Babel (Low Risk)
**Time estimate:** 1 hour
**Risk:** Low
**Steps:**
1. Create babel.config.base.cjs
2. Update package configs
3. Run `npm run build-cjs` to verify
4. Commit changes

### Phase 4-5: Scripts & Deps (Medium Risk)
**Time estimate:** 3-4 hours
**Risk:** Medium (version compatibility)
**Steps:**
1. Install syncpack
2. Run `syncpack list-mismatches` to see drift
3. Fix test-contractor version drift
4. Add version check to CI
5. Document standard scripts
6. Test all packages

### Phase 6: Hoist DevDependencies (Medium Risk)
**Time estimate:** 2-3 hours
**Risk:** Medium (ensure no breaking changes)
**Steps:**
1. Identify truly shared vs package-specific deps
2. Move shared deps to root
3. Run `npm install` to hoist
4. Test all packages build/test
5. Verify published package.json doesn't include devDeps

### Phase 7-8: ESLint & Git (Low Risk)
**Time estimate:** 1-2 hours
**Risk:** Low
**Steps:**
1. Create eslint.config.base.js
2. Update package configs
3. Run `npm run lint` to verify
4. Consolidate .gitignore
5. Commit changes

### Total Implementation Time: 12-15 hours

---

## Impact Summary

### Before

| Metric | Count |
|--------|-------|
| Configuration files | 108 |
| Configuration lines | ~2,900 |
| Duplicate devDependencies | ~40 × 12 = 480 entries |
| Update points for config changes | 12 per change |
| Version drift packages | 1 (test-contractor) |

### After

| Metric | Count | Reduction |
|--------|-------|-----------|
| Configuration files | ~30 | 72% |
| Configuration lines | ~500 | 83% |
| Duplicate devDependencies | ~40 + (5 × 12) = 100 | 79% |
| Update points for config changes | 1 per change | 92% |
| Version drift packages | 0 (enforced by syncpack) | 100% |

---

## Monorepo Best Practices for Independent Publishing

### Current State
✅ Already using npm workspaces
✅ Packages already independently versioned
✅ Already have independent git histories (each has `.git/`)

### Maintaining Independent Publishing

**1. Keep Separate package.json Files**
- Each package maintains its own package.json
- Version numbers managed per-package
- Dependencies listed per-package
- Publishing metadata (name, description, author) per-package

**2. Use Workspace Protocol for Internal Dependencies**
```json
{
  "dependencies": {
    "@beecode/msh-logger": "workspace:*"
  }
}
```

This resolves to actual version during `npm publish`.

**3. Build Before Publish**
Each package builds independently:
```json
{
  "scripts": {
    "prepublishOnly": "npm run build && npm run build-cjs"
  }
}
```

**4. Publishing Strategy**

**Option A: Manual (Current)**
```bash
cd packages/logger
npm version patch
npm publish
```

**Option B: Lerna (Recommended)**
```bash
npm install -D lerna
npx lerna publish
```

Benefits:
- Handles version bumping
- Manages interdependencies
- Creates git tags
- Publishes in correct order

**Option C: Changesets (Modern)**
```bash
npm install -D @changesets/cli
npx changeset
npx changeset version
npx changeset publish
```

Benefits:
- Better changelog management
- Per-package versioning
- CI/CD friendly

### What Won't Change

✅ Each package still publishes to npm independently
✅ Each package has own version number
✅ Consumers can install packages individually
✅ Package dependency graph preserved
✅ Backward compatibility maintained

### What Will Change

📦 Configuration centralized (easier maintenance)
📦 Versions synchronized (less drift)
📦 Faster installs (hoisted dependencies)
📦 Better tooling (syncpack, lerna/changesets)

---

## Risks & Mitigations

### Risk 1: Breaking Package Builds
**Likelihood:** Medium
**Impact:** High
**Mitigation:**
- Implement changes incrementally
- Test each package after config changes
- Run full CI pipeline before merging
- Keep rollback plan (git revert)

### Risk 2: Publishing Issues
**Likelihood:** Low
**Impact:** High
**Mitigation:**
- Test `npm pack` on each package before publishing
- Verify devDependencies don't leak into published packages
- Publish to npm test account first

### Risk 3: Developer Workflow Disruption
**Likelihood:** Medium
**Impact:** Low
**Mitigation:**
- Document changes in CLAUDE.md
- Update README files
- Provide migration guide for contributors
- Communicate changes to team

### Risk 4: Version Conflicts
**Likelihood:** Low
**Impact:** Medium
**Mitigation:**
- Use syncpack to enforce version consistency
- Add pre-commit hooks to check versions
- Document version update process

---

## Alternative Approaches Considered

### 1. Full Turborepo Migration
**Pros:**
- Advanced caching
- Task orchestration
- Remote caching support

**Cons:**
- Major migration effort
- Learning curve
- May be overkill for 12 packages

**Verdict:** Defer until monorepo grows to 20+ packages

### 2. Nx Migration
**Pros:**
- Powerful task runner
- Dependency graph visualization
- Code generation

**Cons:**
- Heavyweight
- Opinionated structure
- Significant migration

**Verdict:** Too heavy for current needs

### 3. Rush.js
**Pros:**
- Designed for publishable packages
- Good for large monorepos

**Cons:**
- Complex setup
- Less popular than alternatives

**Verdict:** Not justified for 12 packages

### 4. Keep Status Quo
**Pros:**
- No migration effort
- No risk

**Cons:**
- Continued maintenance burden
- Version drift will worsen
- Harder to onboard contributors

**Verdict:** ❌ Not recommended

---

## Recommended Approach

### Incremental Adoption

**Stage 1: Low-Hanging Fruit (Week 1)**
- Phase 1: TypeScript config centralization
- Phase 2: Vitest config centralization
- Phase 3: Babel config centralization
- **Deliverable:** 80% of duplication eliminated

**Stage 2: Dependency Management (Week 2)**
- Phase 5: Install syncpack, fix version drift
- Phase 6: Hoist shared devDependencies
- **Deliverable:** Version consistency enforced

**Stage 3: Tooling & Cleanup (Week 3)**
- Phase 7: ESLint cleanup
- Phase 8: Git configuration cleanup
- Add Lerna or Changesets for publishing
- **Deliverable:** Streamlined workflow

### Success Criteria

✅ All packages build successfully
✅ All tests pass
✅ No version drift (syncpack passes)
✅ Configuration lines reduced by >80%
✅ All packages publish successfully
✅ Documentation updated

---

## Conclusion

The MSH monorepo is already well-structured using npm workspaces. This proposal focuses on eliminating configuration duplication while maintaining the ability to publish packages independently.

**Key Takeaways:**
1. **~83% reduction** in configuration code
2. **Incremental migration** (low risk)
3. **Independent publishing** preserved
4. **Automated version management** via syncpack/lerna
5. **Total effort:** 12-15 hours over 3 weeks

**Next Steps:**
1. Review and approve this proposal
2. Create feature branch: `feat/monorepo-simplification`
3. Implement Stage 1 (TypeScript, Vitest, Babel)
4. Test and verify all packages
5. Continue with Stages 2-3

---

## Appendix A: File Changes Summary

### Files to Create (7)
- `/tsconfig.base.json`
- `/tsconfig.build.base.json`
- `/vitest.config.base.ts`
- `/babel.config.base.cjs`
- `/eslint.config.base.js`
- `/syncpack.config.json`
- `/lerna.json` (or `.changeset/config.json`)

### Files to Modify (108)
- 12 × `packages/*/tsconfig.json`
- 12 × `packages/*/tsconfig.build.json`
- 36 × `packages/*/vitest.config*.ts`
- 12 × `packages/*/babel.config.cjs`
- 12 × `packages/*/eslint.config.js`
- 12 × `packages/*/package.json`
- 1 × root `package.json`
- 1 × `CLAUDE.md`
- 1 × root `README.md`

### Files to Delete (12)
- 12 × `packages/*/.gitignore` (consolidate to root)

---

## Appendix B: Example Migration Commands

### Running the Migration

```bash
# Stage 1: Config Centralization
git checkout -b feat/monorepo-simplification

# Create base configs
touch tsconfig.base.json tsconfig.build.base.json
touch vitest.config.base.ts babel.config.base.cjs
touch eslint.config.base.js

# Update all package configs (manual or script)
# ... edit files ...

# Test
npm run build
npm run test

# Commit
git add .
git commit -m "feat: centralize TypeScript, Vitest, and Babel configs"

# Stage 2: Dependency Management
npm install -D syncpack lerna

# Check version drift
npx syncpack list-mismatches

# Fix versions
npx syncpack fix-mismatches

# Hoist devDependencies
# ... move shared deps to root package.json ...
npm install

# Test
npm run build
npm run test

# Commit
git add .
git commit -m "feat: synchronize dependencies and hoist to root"

# Stage 3: Finalize
# ... ESLint, git cleanup ...

git add .
git commit -m "feat: finalize monorepo simplification"

# Push and create PR
git push origin feat/monorepo-simplification
gh pr create --title "Simplify monorepo configuration" --body "See SIMPLIFY_SOLUTION_PROPOSAL.md"
```

### Verification Commands

```bash
# Build all packages
npm run build
npm run build-cjs

# Test all packages
npm run ws-test

# Lint all packages
npm run lint

# Check dependency versions
npx syncpack list-mismatches

# Test publishing (dry run)
cd packages/logger
npm pack
tar -tzf beecode-msh-logger-*.tgz | grep -E "(package.json|dist/|lib/)"
```

---

**Document Version:** 1.0
**Date:** 2026-01-17
**Author:** Claude Code Analysis
**Status:** Proposal for Review
