<!-- .agent-docs/repository-analysis.md -->
<!-- Read this file when analyzing a third-party repository to create a Nix Forge recipe. -->

# Repository Analysis Process for Creating Recipes

This section provides a systematic process for analyzing third-party software repositories and creating Nix Forge recipes.

## Step 1: Identify Build System

Check for these files in the repository (in order of priority):

1. **Python Projects**
   - `pyproject.toml` → Check for `[project.scripts]` or entry points
     - Has CLI tools/executables → Use `pythonAppBuilder`
     - Library/module only → Use `pythonPackageBuilder`
   - `setup.py` → Check for `entry_points` or `console_scripts`
     - Has CLI tools/executables → Use `pythonAppBuilder`
     - Library/module only → Use `pythonPackageBuilder`

2. **CMake Projects**
   - `CMakeLists.txt` → Use `standardBuilder`

3. **Autotools Projects**
   - `configure.ac` or `configure` → Use `standardBuilder`

4. **Makefile Projects**
   - `Makefile` with standard targets (all, install, clean) → Use `standardBuilder`

---

## Step 2: Check Repository Structure

**Critical checks:**

- [ ] **Is the build file in the root directory?** (most common case)
  - If YES: No special configuration needed
  - If NO: Determine the subdirectory

- [ ] **Is the code in a subdirectory?**
  - Example: `geodiff/geodiff/CMakeLists.txt` (build file is in `geodiff/` subdirectory)
  - Solution: Set `build.extraDrvAttrs.sourceRoot = "source/<subdir>";`

- [ ] **Is this a monorepo with multiple projects?**
  - Identify the correct subdirectory for the package you want to build

---

## Step 3: Check for Git Submodules

**IMPORTANT:** The current `source.git` implementation does NOT fetch git submodules.

Check for submodules:
```bash
# Look for .gitmodules file in the repository
# Check repository structure for empty/missing subdirectories
```

**If git submodules exist:**
- Note that dependencies may be missing
- Consider that the build might fail due to missing submodule content
- May need to provide vendored dependencies separately via `nativeBuildInputs`

---

## Step 4: Identify Dependencies

**Where to look:**

1. **CMake projects** (`CMakeLists.txt`):
   - `find_package(<PackageName>)` → Required dependency
   - `pkg_check_modules(<VAR> <package>)` → pkg-config dependency
   - Look for library names and map to nixpkgs

2. **Python projects** (`pyproject.toml`, `setup.py`, `requirements.txt`):
   - `[project.dependencies]` section in pyproject.toml
   - `install_requires` in setup.py
   - Map to `pkgs.python3Packages.<name>`

3. **Autotools projects** (`configure.ac`):
   - `PKG_CHECK_MODULES([VAR], [package])` → pkg-config dependency
   - `AC_CHECK_LIB([library], [function])` → Library dependency

4. **README.md, INSTALL.md, or documentation**:
   - Often lists required dependencies for building

5. **CI Configuration** (`.github/workflows/`, `.gitlab-ci.yml`):
   - Shows what gets installed before building
   - Reveals build and test dependencies

**Dependency categories:**

- **Build tools** (cmake, pkg-config, autoconf, meson, ninja) → `requirements.native`
- **Libraries** (sqlite, gdal, openssl, zlib, postgresql) → `requirements.build`
- **Python packages** → `pkgs.python3Packages.<name>` in dependencies

---

## Step 5: Check for External/Vendored Dependencies

**Warning signs of problematic external downloads:**

- `external/` or `third_party/` directories (may be git submodules)
- `ExternalProject_Add()` in CMakeLists.txt (downloads during build - **PROBLEM!**)
- `FetchContent` in CMake (downloads during build - **PROBLEM!**)
- Download scripts in build files

**If external downloads occur during build:**

Nix builds in a sandbox without network access. You must:

1. **Option 1:** Disable with CMake/build flags
   ```nix
   build.extraDrvAttrs = {
     cmakeFlags = [ "-DUSE_EXTERNAL_LIBS=OFF" ];
   };
   ```

2. **Option 2:** Provide dependencies via nativeBuildInputs
   ```nix
   requirements.native = [ pkgs.somelib ];
   ```

3. **Option 3:** Patch build files to remove download steps
   ```nix
   build.extraDrvAttrs = {
     postPatch = ''
       substituteInPlace CMakeLists.txt \
         --replace-fail "ExternalProject_Add" "# ExternalProject_Add"
     '';
   };
   ```

---

## Step 6: Find the Main Executable

**Where to look:**

- `bin/` directory in source code
- CMake: `add_executable(<name> ...)` in CMakeLists.txt
- Python: `[project.scripts]` in pyproject.toml or `entry_points` in setup.py
- README.md usage examples (e.g., `$ geodiff --help`)

**Set in recipe:**
```nix
mainProgram = "executable-name";  # Just the binary name, not the path
```

---

## Step 7: Identify Latest Version

- Check GitHub releases page for latest stable release
- Prefer released versions over git commit hashes
- Use version tags (e.g., `v1.2.3` or `1.2.3`)

---

## Step 8: Identify Tests

**Where to look:**

- `test/` or `tests/` directory
- CMake: `enable_testing()`, `add_test()`, or `BUILD_TESTING` option
- Python: `pytest`, `unittest`, test files matching `test_*.py`
- CI configuration shows test commands

**For recipe test.script:**

- **Minimum:** `--version` and `--help` flags
- **Better:** Simple import test (Python), basic functional test
- **Keep fast:** Tests should complete in < 10 seconds

---

## Common Build Issues and Solutions

### Issue 1: "CMakeLists.txt not found"

**Error message:**
```
CMake Error: The source directory does not appear to contain CMakeLists.txt
```

**Diagnosis:** Build files are in a subdirectory, not the root.

**Solution:**
```nix
build.extraDrvAttrs = {
  sourceRoot = "source/<subdirectory>";
};
```

**Example:**
```nix
build.extraDrvAttrs = {
  sourceRoot = "source/geodiff";  # For geodiff/geodiff/CMakeLists.txt
};
```

---

### Issue 2: "Cannot download during build"

**Error message:**
```
CMake Error at CMakeLists.txt:104 (INCLUDE):
  INCLUDE could not find requested file:
    /build/source/build/external/libgpkg-.../UseTLS.cmake
```

**Diagnosis:**
- CMake tries to download dependencies with `ExternalProject_Add()` or `FetchContent`
- Git submodules not fetched
- Build downloads external resources

**Solutions:**

1. **Disable downloads via CMake flags:**
   ```nix
   build.extraDrvAttrs = {
     cmakeFlags = [ "-DUSE_SYSTEM_LIBS=ON" "-DENABLE_EXTERNAL_DOWNLOAD=OFF" ];
   };
   ```

2. **Provide missing dependencies:**
   ```nix
   requirements.build = [ pkgs.libgpkg ];  # If available in nixpkgs
   ```

3. **Patch CMakeLists.txt:**
   ```nix
   build.extraDrvAttrs = {
     postPatch = ''
       substituteInPlace CMakeLists.txt \
         --replace-fail "include(ExternalProject)" ""
     '';
   };
   ```

---

### Issue 3: "Python dependency version mismatch"

**Error message:**
```
ERROR Missing dependencies:
  cython~=3.0.2
```

**Diagnosis:** Python package requires specific version, but nixpkgs has different version.

**Solution:** Relax version constraint by patching pyproject.toml:
```nix
build.extraDrvAttrs = {
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "cython~=3.0.2" cython
  '';
};
```

---

### Issue 4: "Missing Python runtime dependencies"

**Error message:**
```
Checking runtime dependencies for package.whl
  - attrs not installed
  - click not installed
```

**Diagnosis:** Python package has runtime dependencies not listed in recipe.

**Solution:** Add missing packages to dependencies:
```nix
build.pythonAppBuilder = {
  requirements = {
    dependencies = [
      pkgs.python3Packages.attrs
      pkgs.python3Packages.click
      # ... other dependencies
    ];
  };
};
```

---

### Issue 5: "Tests enabled but fail or unwanted"

**Diagnosis:** Build system enables tests by default, but they fail or slow down build.

**Solutions:**

For CMake:
```nix
build.extraDrvAttrs = {
  cmakeFlags = [ "-DENABLE_TESTS=OFF" "-DBUILD_TESTING=OFF" ];
};
```

For Meson:
```nix
build.extraDrvAttrs = {
  mesonFlags = [ "-Dtests=false" ];
};
```

For Autotools:
```nix
build.extraDrvAttrs = {
  configureFlags = [ "--disable-tests" ];
};
```

---

## Builder Selection Decision Tree

```
START: What type of project is this?

├─ Has pyproject.toml or setup.py?
│  └─ YES → Python Project
│     ├─ Check pyproject.toml for [project.scripts] or setup.py for entry_points
│     ├─ Has executable entry points?
│     │  ├─ YES → Use pythonAppBuilder (CLI tools, applications)
│     │  │     ├─ build-system: setuptools, cython, etc.
│     │  │     └─ dependencies: runtime Python packages
│     │  └─ NO → Use pythonPackageBuilder (libraries, modules)
│     │        ├─ build-system: setuptools, cython, etc.
│     │        └─ dependencies: runtime Python packages
│
├─ Has CMakeLists.txt?
│  └─ YES → Use standardBuilder
│     ├─ native: cmake, pkg-config
│     └─ build: libraries (sqlite, gdal, etc.)
│
├─ Has configure or configure.ac?
│  └─ YES → Use standardBuilder (Autotools)
│     ├─ native: autoconf, automake, libtool, pkg-config
│     └─ build: libraries
│
└─ Has Makefile with standard targets?
   └─ YES → Use standardBuilder
      ├─ Check for: all, install, clean targets
      ├─ native: make, pkg-config
      └─ build: libraries
      └─ For custom configuration: use build.extraDrvAttrs
```
