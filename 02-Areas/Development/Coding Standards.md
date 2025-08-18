---
created: 2025-08-18
modified: 2025-08-18
type: reference
tags: [development, standards, code-style, ai-reference]
---

# Coding Standards and Preferences

## General Principles
- **Readability > Cleverness:** Code is read more than written
- **Explicit > Implicit:** Clear intent over magic
- **Consistent > Perfect:** Team/project consistency matters most
- **Tested > Untested:** If it's not tested, it's broken
- **Simple > Complex:** Start simple, add complexity only when needed

## Code Style Preferences
### Naming Conventions
- **Variables:** camelCase for JS/TS, snake_case for Python
- **Constants:** UPPER_SNAKE_CASE
- **Functions:** Verb phrases (getUserData, calculateTotal)
- **Classes:** PascalCase, noun phrases
- **Files:** kebab-case for most, PascalCase for components

### Comment Philosophy
- Code should be self-documenting when possible
- Comments explain "why" not "what"
- TODOs include ticket numbers or assignee
- Keep comments updated or delete them
- Doc strings for public APIs

### Function Design
```typescript
// Preferred: Pure, testable, single responsibility
function calculateDiscount(price: number, discountPercent: number): number {
  return price * (1 - discountPercent / 100);
}

// Avoid: Side effects, multiple responsibilities
function processOrder(order) {
  // Updates database, sends email, calculates price...
}
```

## Language-Specific
### TypeScript/JavaScript
- Prefer TypeScript for any non-trivial project
- Use strict mode always
- Const by default, let when needed, never var
- Async/await over callbacks or raw promises
- Functional patterns where appropriate

### Python
- Follow PEP 8 with Black formatter
- Type hints for public functions
- Dataclasses over dictionaries for structured data
- List comprehensions for simple transformations
- Context managers for resource handling

### Swift
- SwiftUI over UIKit for new projects
- Combine for reactive patterns
- Guard for early returns
- Extensions for organization
- Protocol-oriented design

## Project Structure
### Typical Organization
```
project/
├── src/
│   ├── components/    # UI components
│   ├── services/      # Business logic
│   ├── utils/         # Helpers
│   ├── types/         # TypeScript types
│   └── config/        # Configuration
├── tests/
│   ├── unit/
│   └── integration/
├── docs/
└── scripts/           # Build and utility scripts
```

### File Organization
- One component/class per file generally
- Related utilities can share a file
- Test files mirror source structure
- Config separate from code

## Testing Philosophy
### Test Pyramid
1. **Unit Tests:** Many, fast, isolated
2. **Integration Tests:** Some, slower, real dependencies
3. **E2E Tests:** Few, slowest, full user flows

### What to Test
- Business logic always
- Edge cases and error paths
- Public APIs
- Critical user paths
- Complex algorithms

### What Not to Test
- Framework functionality
- Third-party libraries
- Trivial getters/setters
- UI implementation details

## Error Handling
### Principles
- Fail fast in development
- Graceful degradation in production
- Log errors with context
- User-friendly error messages
- Never swallow errors silently

### Pattern
```typescript
try {
  return await riskyOperation();
} catch (error) {
  logger.error('Operation failed', { error, context });
  // Handle specifically if possible
  if (error instanceof SpecificError) {
    return fallbackValue;
  }
  // Re-throw if can't handle
  throw error;
}
```

## Performance Considerations
### Optimize When
- Profiling shows actual bottleneck
- User experience is affected
- Costs are significant (API calls, compute)

### Common Optimizations
- Memoization for expensive calculations
- Pagination for large lists
- Lazy loading for heavy resources
- Caching for repeated API calls
- Debouncing for user input

## Git Practices
### Commit Messages
```
type(scope): subject

body (optional)

footer (optional)
```

Types: feat, fix, docs, style, refactor, test, chore

### Branch Strategy
- main/master: Production ready
- develop: Integration branch
- feature/*: New features
- fix/*: Bug fixes
- release/*: Release preparation

## Code Review Checklist
When reviewing or writing:
- [ ] Does it solve the problem?
- [ ] Is it readable and maintainable?
- [ ] Are edge cases handled?
- [ ] Is it tested appropriately?
- [ ] Does it follow project conventions?
- [ ] Are there security concerns?
- [ ] Will it scale if needed?

## Security Basics
- Never commit secrets
- Validate all inputs
- Sanitize user content
- Use HTTPS always
- Keep dependencies updated
- Principle of least privilege
- Log security events

## Documentation Standards
### README Must Include
- Project purpose
- Quick start guide
- Installation steps
- Basic usage examples
- Contributing guidelines
- License information

### Code Documentation
- Public APIs need documentation
- Complex algorithms need explanation
- Non-obvious decisions need justification
- Setup/deployment needs step-by-step guide

---
*This document helps AI assistants write code that matches my style and standards.*