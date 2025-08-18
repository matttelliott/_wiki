---
created: 2025-08-18
modified: 2025-08-18
type: style-guide
tags: [writing, documentation, standards, ai-reference]
---

# Writing Style Guide

## General Principles
- **Clarity First:** Clear communication over clever writing
- **Conciseness:** Say more with less, avoid fluff
- **Actionable:** Focus on what can be done, not just theory
- **Scannable:** Use headers, bullets, and formatting for easy scanning

## Tone & Voice
### For Technical Documentation
- Direct and precise
- Minimal jargon unless necessary
- Examples over abstract explanations
- Assume competent but busy reader

### For Personal Notes
- Conversational but focused
- Future-self as audience
- Include context that might be forgotten
- Link liberally to related concepts

### For Project Documentation
- Professional but approachable
- Problem → Solution structure
- Include "why" not just "what"
- Success criteria clearly defined

## Formatting Preferences
### Headers
- Use sentence case (not Title Case)
- Hierarchical and logical
- Maximum 3 levels deep in most documents
- Emoji sparingly (only for visual markers in special sections)

### Lists
- Bullet points for unordered items
- Numbered lists only when order matters
- Sub-items only when necessary
- Each item should be scannable

### Code Blocks
```language
// Always specify language for syntax highlighting
// Include context comments when helpful
// Keep examples minimal but complete
```

### Emphasis
- **Bold** for important concepts first mention
- *Italic* for gentle emphasis or quotes
- `code` for technical terms, commands, file names
- AVOID CAPS except for acronyms

## Document Structure
### Standard Sections
1. **Purpose/Context** - Why this exists
2. **Core Content** - The main information
3. **Examples** - Concrete applications
4. **Next Steps** - What to do with this information
5. **References** - Links and related materials

### Metadata
- Always include frontmatter
- Keep tags consistent and minimal
- Date created and modified
- Type classification

## Naming Conventions
### Files
- Lowercase with hyphens for spaces: `my-document.md`
- Descriptive but concise
- No special characters except hyphens
- Date prefix for time-sensitive: `2025-08-18-meeting.md`

### Titles
- Clear and descriptive
- Include context when needed
- Avoid generic names like "Notes" or "Ideas"

## Common Patterns
### Task Documentation
```
## Task: [Clear action verb + object]
**Context:** [Why this needs doing]
**Steps:**
1. [Specific action]
2. [Specific action]
**Success Criteria:** [How we know it's done]
```

### Meeting Notes
```
# Meeting: [Topic] - [Date]
**Participants:** [Names]
**Purpose:** [Why we met]
## Key Decisions
- [Decision and rationale]
## Action Items
- [ ] [Owner]: [Task] - Due: [Date]
## Notes
[Discussion points]
```

### Learning Notes
```
# [Topic]
**Source:** [Book/Article/Video]
**Key Insight:** [One sentence summary]
## Concepts
[Main ideas explained]
## Applications
[How this applies to my work/life]
## Questions
[What I still need to understand]
```

## AI Assistant Instructions
When creating content for this wiki:
1. Follow these style guidelines
2. Maintain consistency with existing content
3. Err on the side of being too clear
4. Include examples when concepts are abstract
5. Create links to related notes (even if they don't exist yet)
6. Use templates when available
7. Keep future discoverability in mind

## Things to Avoid
- Walls of text without breaks
- Overly technical language without explanation
- Passive voice when active works
- Speculation without marking it as such
- Duplicate information across documents (link instead)
- Screenshots without context
- External links without description

---
*This guide ensures consistency across all wiki entries and helps AI assistants match my preferred style.*