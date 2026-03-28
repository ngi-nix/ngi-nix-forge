<!-- .agent-docs/overview.md -->
<!-- Read this file to understand what Nix Forge is and what types of projects it supports. -->

# Nix Forge Overview

This specification guides LLMs in generating Nix Forge recipes - declarative configuration files for building software packages and applications.

## Supported Project Types

**IMPORTANT:** Nix Forge currently supports the following types of projects:

1. **Python applications** - Projects with `pyproject.toml` or `setup.py` that provide CLI tools (use `pythonAppBuilder`)
2. **Python libraries** - Projects with `pyproject.toml` or `setup.py` meant to be imported by other packages (use `pythonPackageBuilder`)
3. **CMake-based projects** - Projects with `CMakeLists.txt` (use `standardBuilder`)
4. **Autotools-based projects** - Projects with `configure` or `configure.ac` (use `standardBuilder`)
5. **Makefile-based projects** - Projects with standard `Makefile` targets (use `standardBuilder`)

## Summary

When generating a Nix Forge recipe:

1. **Identify** the software and gather information
2. **Choose** appropriate builder based on build system
3. **Define** source (git or url with hash)
4. **List** all dependencies in correct categories
5. **Write** meaningful test script
6. **Validate** against checklist
7. **Format** consistently with examples

The goal is a **declarative, reproducible, and testable** package definition that abstracts Nix complexity while maintaining flexibility.
