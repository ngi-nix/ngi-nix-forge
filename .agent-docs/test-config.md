<!-- .agent-docs/test-config.md -->
<!-- Read this file when configuring tests for recipes. -->

# Test Configuration

```nix
test = {
  requirements = [ pkgs.curl ];  # Additional test dependencies
  script = ''
    # Test commands
    $out/bin/program --version
    $out/bin/program --help
  '';
};
```

**Best practices**:
- Test main functionality
- Verify version output
- Check help/usage works
- Keep tests fast (< 10 seconds)
