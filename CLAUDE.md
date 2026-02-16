# MSH (Micro-Service Helper)

A collection of decoupled micro-framework tools for TypeScript/Node.js projects. Monorepo using npm workspaces containing 12 packages.

## Quick Reference

```bash
# Install & setup
npm install
npm run ws-init              # Initialize all workspaces

# Build
npm run build                # Build all packages (ESM -> dist/)
npm run build-cjs            # Build all packages (CommonJS -> lib/)
npm run clean                # Clean dist/ directories

# Test
npm run ws-test              # Run tests in all workspaces

# Lint
npm run lint                 # Run all linters
npm run lint-fix             # Auto-fix linting issues

# Development
npm run watch                # Watch mode (build + clean)
```

## Tech Stack

- **Runtime:** Node.js 22.14.0+, npm 10.9.2+
- **Language:** TypeScript 5.7.3+ (ESM with CommonJS output)
- **Testing:** Vitest 3.0.9+
- **Linting:** ESLint + Prettier (via @beecode/msh-config)
- **Build:** TypeScript compiler + Babel (for CJS)

## Project Structure

```
packages/
├── config/          # Shared ESLint & Prettier configs
├── error/           # Error handling with HTTP codes
├── util/            # Utility functions
├── node-session/    # Session management (cls-hooked)
├── logger/          # Logging abstraction
├── env/             # Environment variable validation
├── cli/             # Multi-repo project management CLI
├── test-contractor/ # Contract-based testing (WIP)
├── app-boot/        # App initialization & lifecycle
├── entity/          # Entity management (WIP)
├── orm/             # ORM abstraction (WIP)
└── base-frame/      # Project templating tool
```

## Code Conventions

- **Imports:** Use `#src` path aliases (e.g., `import { x } from '#src/util'`)
- **Formatting:** Tabs (size 2), max line 130 chars, single quotes, no semicolons
- **Tests:** `*.test.ts` (unit), `*.int.test.ts` (integration), placed in `src/__tests__/`
- **Commits:** Conventional commits (enforced by commitlint)

## Key Patterns

- **Strategy Pattern:** Used extensively for logging, sessions, env location
- **Lifecycle Pattern:** AppFlow and LifeCycle classes for initialization
- **Dual Output:** All packages compile to both ESM (dist/) and CommonJS (lib/)

## Package Commands

Each package supports:
```bash
npm run build         # Build package
npm run test          # Run all tests
npm run test:unit     # Unit tests only
npm run test:int      # Integration tests only
npm run lint          # Check code quality
npm run lint-fix      # Auto-fix issues
npm run doc           # Generate API docs
```

## Clean TypeScript Skill

This project uses the **clean-typescript** skill for Claude Code assistance. When working on this codebase, leverage the skill for:
- Creating services, repositories, DALs, entities
- Building controllers, handlers, use cases
- Writing unit tests with Vitest
- Following established TypeScript patterns in the codebase
