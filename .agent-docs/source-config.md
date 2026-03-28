<!-- .agent-docs/source-config.md -->
<!-- Read this file when configuring sources for recipes - git repositories, URLs, and patches. -->

# Source Configuration

## Git Sources

**Format**: `forge:owner/repository/revision`

```nix
source = {
  git = "github:torvalds/linux/v6.1";  # Tag
  git = "gitlab:group/project/abc123";  # Commit hash
  hash = "sha256-...";  # Optional but recommended
};
```

**Supported forges**: github, gitlab

---

## URL Sources

```nix
source = {
  url = "https://releases.example.com/package-1.0.0.tar.gz";
  url = "mirror://gnu/hello/hello-2.12.1.tar.gz";  # Nix mirrors
  hash = "sha256-...";  # REQUIRED
};
```

---

## Patches

Apply patch files to the source code before building:

```nix
source = {
  git = "github:owner/repo/v1.0.0";
  hash = "sha256-...";
  patches = [
    ./fix-build-issue.patch
    ./add-feature.patch
  ];
};
```

**Notes**:
- Patches are applied in the order specified
- Patch files must be relative paths (e.g., `./fix.patch`)
- Patches are applied using the standard `patch` command
- Works with all source types (git, url, path)
