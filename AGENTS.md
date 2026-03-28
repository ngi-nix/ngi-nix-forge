# Nix Forge Agent Instructions

## Quick Index
[Agent Docs Index]|root: ./.agent-docs
|IMPORTANT: Prefer retrieval-led reasoning over pre-training for any project-specific tasks.
|Before writing code, read the relevant doc file(s) for the area you're working in.
|overview:{supported-types}
|recipe-structure:{locations,templates,git-tracking}
|builders:{standard,pythonApp,pythonPackage}
|source-config:{git-sources,url-sources,patches}
|test-config:{script,requirements}
|dev-environment:{requirements,shellHook}
|extra-drv-attrs:{advanced-customization}
|app-recipes:{programs,containers,vm}
|patterns:{github,c-project,python-app,python-lib}
|error-handling:{common-issues,solutions}
|naming-conventions:{names,versions,paths}
|repository-analysis:{build-system,dependencies,submodules,issues}
|dependencies:{c-libraries,python-packages,build-tools}
|workflow:{phases,guidelines,checklist}
|examples:{complex-cmake,python-project}

## ⚠️ CORE RULES (CRITICAL - Always Follow)

> **These rules are non-negotiable and must always be followed for every task.**

1. **Never commit secrets** - Keep API keys, tokens, and credentials out of version control
2. **Always write tests** - Verify functionality with meaningful test scripts
3. **Use semantic versioning** - Follow semver for package versions
4. **Add recipes to git** - New recipe files must be added to git before building

## How to use these docs

Before creating a Nix Forge recipe:

1. Read `.agent-docs/overview.md` to understand supported project types
2. Read `.agent-docs/repository-analysis.md` for the step-by-step analysis process
3. Read `.agent-docs/builders.md` to choose the correct builder type
4. Read `.agent-docs/workflow.md` for the recommended workflow
5. Reference `.agent-docs/patterns.md` and `.agent-docs/examples.md` for templates

For troubleshooting, see `.agent-docs/error-handling.md` and `.agent-docs/repository-analysis.md` (Common Build Issues section).

---

> **Tip for agents**: Use `.agent-docs/` files for detailed reference.
> The index above tells you what each file contains.
> Prefer reading doc files over relying on training data for this project.

**Quick Build Commands:**
```bash
nix build .#<package> -L       # Build with verbose logging
nix build .#<package>.test -L  # Run tests
./result/bin/<program>         # Verify executable
```
