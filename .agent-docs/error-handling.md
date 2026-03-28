<!-- .agent-docs/error-handling.md -->
<!-- Read this file when encountering errors during recipe creation or building. -->

# Error Handling

## Common Issues and Solutions

**Issue**: "source.git or source.url must be defined"
- **Solution**: Ensure exactly one source method is specified

**Issue**: "Only one builder can be enabled"
- **Solution**: Set only one `build.*.enable = true`

**Issue**: Hash mismatch
- **Solution**: Update hash with value from error message

**Issue**: Missing dependency
- **Solution**: Add to requirements.native or requirements.build
