<!-- .agent-docs/workflow.md -->
<!-- Read this file for the recommended workflow when creating Nix Forge recipes from git repositories. -->

# Recommended LLM Workflow

When asked to create a Nix Forge recipe from a git repository, follow this workflow:

## Phase 1: Research & Analysis

**Use the Task/Plan agent to gather information:**

1. Fetch and read repository README.md
2. Identify build system (check for CMakeLists.txt, pyproject.toml, etc.)
3. Check repository structure (is build file in root or subdirectory?)
4. Identify latest stable version from GitHub releases
5. List dependencies from build files and documentation
6. Find main executable/program name
7. Check for tests

**Output from this phase:** Comprehensive summary with all required information.

---

## Phase 2: Create Initial Recipe

1. Create package directory: `mkdir -p recipes/packages/<name>`
2. Write `recipe.nix` with:
   - Basic metadata (name, version, description, homePage, mainProgram)
   - Appropriate builder (pythonAppBuilder, pythonPackageBuilder, or standardBuilder)
   - `source.hash = ""` (leave empty initially)
   - Initial dependencies based on research
   - Basic test script (at minimum: `--help` and `--version`)

---

## Phase 3: Add to Git (CRITICAL!)

```bash
git add recipes/packages/<package-name>/recipe.nix
```

**Without this step, the package will not be recognized by the flake!**

---

## Phase 4: Iterative Build & Fix

1. **First build attempt:**
   ```bash
   nix build .#<package> -L
   ```

2. **Get correct hash:**
   - Build will fail with hash mismatch
   - Update `source.hash` with the correct value from error message

3. **Rebuild and fix errors iteratively:**
   ```bash
   nix build .#<package> -L
   ```

   Common fixes needed:
   - Add missing dependencies to `requirements.native` or `requirements.build`
   - Set `sourceRoot` if CMakeLists.txt not in root
   - Patch build files to remove external downloads
   - Relax Python version constraints
   - Disable unwanted tests

4. **Repeat until build succeeds**

---

## Phase 5: Test & Verify

1. Run package tests:
   ```bash
   nix build .#<package>.test -L
   ```

2. Verify tests pass

3. Manual verification (optional):
   ```bash
   ./result/bin/<program> --version
   ./result/bin/<program> --help
   ```

---

## LLM Generation Guidelines

### 1. Information Gathering
Before generating a recipe, determine:
- **Software name and version**
- **Programming language/build system**
- **Source location** (GitHub URL, release tarball)
- **Build dependencies** (libraries, tools)
- **Runtime dependencies**
- **Main executable name**

### 2. Builder Selection Logic
```
IF Python project with pyproject.toml:
  IF provides CLI tools/executables (has [project.scripts] or entry_points):
    → pythonAppBuilder
  ELSE IF library meant to be imported:
    → pythonPackageBuilder

ELSE IF has configure script OR uses CMake OR standard Makefile:
  → standardBuilder
  (Use build.extraDrvAttrs for custom build configuration)
```

### 3. Dependency Resolution
- **Build tools**: cmake, pkg-config, autoconf → `requirements.native`
- **Libraries**: openssl, zlib, curl → `requirements.build`
- **Python packages**: Use `pkgs.python3Packages.*`
- **Unknown packages**: Use `pkgs.<package-name>`

### 4. Hash Determination
When hash is unknown:
```nix
source.hash = "";  # Leave empty initially
# Nix will error with correct hash, then update recipe
```

### 5. Validation Checklist
- [ ] Exactly one builder enabled (standardBuilder, pythonAppBuilder, or pythonPackageBuilder)
- [ ] For Python projects: correct builder chosen (pythonAppBuilder for apps, pythonPackageBuilder for libraries)
- [ ] Source has git XOR url (not both)
- [ ] Hash present for URL sources
- [ ] name is lowercase-with-hyphens
- [ ] mainProgram matches actual executable
- [ ] Test script tests main functionality
- [ ] No hardcoded /nix/store paths

---

## Quick Reference Checklist

Before creating a recipe, gather this information:

- [ ] Project name (lowercase-with-hyphens)
- [ ] Latest stable version
- [ ] Build system type (Python app/library/CMake/Autotools/Makefile)
- [ ] For Python: Does it provide CLI tools or is it a library?
- [ ] Main executable name (if applicable)
- [ ] Homepage URL
- [ ] Build dependencies (libraries, tools)
- [ ] Runtime dependencies
- [ ] Repository structure (root or subdirectory?)
- [ ] Git submodules present? (if yes, note limitations)
- [ ] Test commands available?

During recipe creation:

- [ ] Choose correct builder (pythonAppBuilder for apps, pythonPackageBuilder for libraries, or standardBuilder)
- [ ] Leave source.hash empty initially
- [ ] Add recipe to git BEFORE building
- [ ] Build to get correct hash
- [ ] Fix errors iteratively
- [ ] Verify tests pass
