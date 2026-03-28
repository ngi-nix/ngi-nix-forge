<!-- .agent-docs/builders.md -->
<!-- Read this file to understand the three builder types and when to use each one. -->

# Builder Types

## Required Fields

```nix
{
  name = "package-name";           # String, lowercase with hyphens
  version = "1.0.0";               # String, semantic versioning
  description = "Short description of the package.";

  # Source: EXACTLY ONE of these must be defined
  source.git = "github:owner/repo/commit-or-tag";  # OR
  source.url = "https://...";
  source.hash = "sha256-...";      # Required with url, optional with git

  # Builder: EXACTLY ONE must be enabled
  build.standardBuilder.enable = true;     # OR
  build.pythonAppBuilder.enable = true;    # OR
  build.pythonPackageBuilder.enable = true;
}
```

### Optional but Recommended Fields

```nix
{
  homePage = "https://project-website.org";
  mainProgram = "executable-name";  # Main binary name for the package
}
```

---

## 1. standardBuilder (Most Common)

**When to use**: Standard autotools/cmake/make-based projects

```nix
{
  build.standardBuilder = {
    enable = true;
    requirements.native = [
      pkgs.cmake
      pkgs.pkg-config
    ];
    requirements.build = [
      pkgs.openssl
      pkgs.zlib
    ];
  };
}
```

**Characteristics**:
- Automatic configure, build, install phases
- Follows standard build conventions
- Use for: C/C++ projects with configure scripts or CMake

---

## 2. pythonAppBuilder (Python Applications)

**When to use**: Python applications with pyproject.toml that provide executable programs

```nix
{
  build.pythonAppBuilder = {
    enable = true;
    requirements = {
      build-system = [
        pkgs.python3Packages.setuptools
      ];
      dependencies = [
        pkgs.python3Packages.flask
        pkgs.python3Packages.requests
      ];
      optional-dependencies = {      # PEP-621 extras (optional)
        dev = [
          pkgs.python3Packages.pytest
        ];
      };
    };
    importsCheck = [ "myapp" ];      # Verify imports work (optional)
    relaxDeps = [ "flask" ];         # Remove version constraints (optional)
    disabledTests = [ "test_network" ]; # Skip specific tests (optional)
  };
}
```

**Characteristics**:
- Uses `buildPythonApplication` internally
- Creates standalone applications with entry points
- Prevents the package from being used as a dependency by other Python packages
- Use for: CLI tools, web applications, standalone Python programs

**Additional Options**:
- **optional-dependencies**: PEP-621 optional dependency groups (extras) → nixpkgs: `optional-dependencies`
- **importsCheck**: List of modules to verify can be imported → nixpkgs: `pythonImportsCheck`
- **relaxDeps**: Remove version constraints → nixpkgs: `pythonRelaxDeps`
- **disabledTests**: Skip specific pytest test names → nixpkgs: `disabledTests`

---

## 3. pythonPackageBuilder (Python Libraries)

**When to use**: Python libraries/packages with pyproject.toml that other packages depend on

```nix
{
  build.pythonPackageBuilder = {
    enable = true;
    requirements = {
      build-system = [
        pkgs.python3Packages.setuptools
      ];
      dependencies = [
        pkgs.python3Packages.numpy
        pkgs.python3Packages.attrs
      ];
      optional-dependencies = {      # PEP-621 extras (optional)
        dev = [
          pkgs.python3Packages.pytest
        ];
      };
    };
    importsCheck = [ "mylib" ];      # Verify imports work (optional)
    relaxDeps = [ "numpy" ];         # Remove version constraints (optional)
    disabledTests = [ "test_slow" ]; # Skip specific tests (optional)
  };
}
```

**Characteristics**:
- Uses `buildPythonPackage` internally
- Creates reusable Python libraries
- Can be used as dependencies by other Python packages
- Use for: Python libraries, frameworks, utility modules

**Note**: Use pkgs.python3Packages.* for Python dependencies

**Choosing between pythonAppBuilder and pythonPackageBuilder**:
- **pythonAppBuilder**: For programs meant to be run (`mypy`, `black`, `fio`)
- **pythonPackageBuilder**: For libraries meant to be imported (`requests`, `numpy`, `attrs`)
