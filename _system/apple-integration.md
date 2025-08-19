# Apple Ecosystem Integration Guide

## 🍎 Overview
This guide helps you integrate your Obsidian vault with Apple's native apps and services for seamless productivity across iPhone, iPad, and Mac.

## 📱 iOS & macOS Compatibility

### Storage Setup
1. **Use iCloud Drive** for automatic sync
   - Store vault in `iCloud Drive/Obsidian/`
   - Enable "Optimize Mac Storage" cautiously
   - Keep vault under 1GB for best performance

2. **Alternative: Obsidian Sync**
   - More reliable than iCloud
   - Works across all platforms
   - Requires subscription

### File Naming Rules
- Avoid these characters: `/ \ : * ? " < > |`
- Keep paths under 255 characters
- Use hyphens or underscores instead of spaces
- Maintain consistent case (iOS is case-sensitive)

## ✅ Apple Reminders Integration

### Quick Capture Setup
1. **Create Reminders List** called "Obsidian Inbox"
2. **Use Siri** for hands-free capture:
   - "Hey Siri, add to my Obsidian Inbox list..."
   - "Hey Siri, remind me to review project X"

### Processing Workflow
```markdown
Daily Review Process:
1. Open Reminders app
2. Review "Obsidian Inbox" list
3. For each item:
   - Create task in Obsidian with context
   - Add due date if specified
   - Delete from Reminders
```

### Task Format for Compatibility
```markdown
- [ ] Task name #@context ^due(2024-01-20) !priority
     Compatible with most task plugins
```

### Recommended Plugins
- **Tasks Plugin** - Full task management
- **Reminder Plugin** - Sync with Apple Reminders
- **Natural Language Dates** - Parse dates easily

## 📅 Apple Calendar Integration

### Calendar Blocking
1. **Weekly Review** - Recurring Sunday 2-3:30pm
2. **Daily Planning** - Recurring weekdays 8:30-9am
3. **Deep Work Blocks** - Schedule project time

### Meeting Notes Workflow
1. Calendar event includes Obsidian link
2. Use URL scheme: `obsidian://open?vault=YourVault&file=Meeting%20Note`
3. Create meeting note from template
4. Link back to calendar with: `x-apple-calevent://`

### Event Capture Template
```markdown
## Meeting: {{title}}
Date: [[{{date}}]]
Attendees: {{attendees}}
Calendar Link: [Open in Calendar]({{calendar-link}})

### Agenda
{{agenda}}

### Notes
- 

### Action Items
- [ ] 
```

## 🎯 Apple Shortcuts Integration

### Essential Shortcuts

#### 1. Quick Capture
```
Shortcut Name: Obsidian Quick Capture
Actions:
1. Ask for Text Input
2. Get Current Date
3. Create Note in Obsidian
4. Add to Inbox folder
```

#### 2. Daily Note
```
Shortcut Name: Open Today's Note
Actions:
1. Get Current Date (format: YYYY-MM-DD)
2. Open URL: obsidian://open?vault=_wiki_&file=04-Daily%2F{{date}}
```

#### 3. Project Template
```
Shortcut Name: New Project
Actions:
1. Ask for Project Name
2. Choose from List (priority)
3. Create from Template
4. Open in Obsidian
```

### Shortcut Installation
1. Open Shortcuts app
2. Tap "+" to create new
3. Add Obsidian actions
4. Add to Home Screen or Widget

## 📲 Mobile Optimization

### iOS App Settings
```
Settings → Editor:
- Fold heading: ON
- Fold indent: ON  
- Show line number: OFF
- Readable line length: ON
- Strict line breaks: OFF

Settings → Appearance:
- Base font size: 16
- Quick font size adjustment: ON
- Show inline title: ON
```

### Touch-Friendly CSS
Create `_System/mobile.css`:
```css
/* Larger touch targets */
.mobile .checkbox-container {
  padding: 10px;
  min-height: 44px;
}

/* Better spacing */
.mobile .markdown-preview-view {
  padding: 20px;
  line-height: 1.6;
}

/* Larger buttons */
.mobile .nav-action-button {
  padding: 12px;
}
```

### Mobile Plugins (iOS Compatible)
- **Templater** - Template management
- **Periodic Notes** - Daily/weekly notes
- **Tasks** - Task management
- **Dataview** - Dynamic queries
- **QuickAdd** - Quick capture
- **Natural Language Dates** - Date parsing

## 🔄 Sync Strategies

### iCloud Drive Setup
1. Place vault in `iCloud Drive/Obsidian/`
2. Wait for initial sync (can take time)
3. Always close app properly
4. Don't edit during sync

### Conflict Resolution
- Files ending in ` (conflict)` need manual merge
- Check modification dates
- Keep backup before resolving
- Use version history if available

### Sync Checklist
- [ ] Close Obsidian on device A
- [ ] Wait for sync indicator
- [ ] Open on device B
- [ ] Make changes
- [ ] Close and wait
- [ ] Reopen on device A

## 🔗 URL Schemes

### Opening Notes
```
obsidian://open?vault=_wiki_&file=Note%20Name
```

### Creating Notes
```
obsidian://new?vault=_wiki_&name=New%20Note&content=Content
```

### Searching
```
obsidian://search?vault=_wiki_&query=search%20term
```

### From Other Apps
- Bear: `bear://x-callback-url/open-note?id=`
- Things: `things:///show?id=`
- OmniFocus: `omnifocus:///task/`

## 🛠 Troubleshooting

### Common iOS Issues

#### Sync Not Working
1. Check iCloud storage space
2. Force quit and reopen
3. Toggle iCloud Drive off/on
4. Restart device

#### Can't Open Vault
1. Check vault location is in iCloud
2. Verify no special characters in path
3. Ensure files are downloaded
4. Reinstall if needed

#### Performance Issues
- Reduce vault size
- Disable heavy plugins
- Clear cache in settings
- Limit open tabs

### Widget Setup
1. Long press home screen
2. Tap "+" for widgets
3. Search "Shortcuts"
4. Add shortcut widget
5. Select Obsidian shortcuts

## 📝 Best Practices

### Do's
- ✅ Regular backups to separate location
- ✅ Use simple folder structure
- ✅ Test plugins on desktop first
- ✅ Keep mobile vault focused
- ✅ Use shortcuts for repetitive tasks

### Don'ts
- ❌ Edit same note on multiple devices simultaneously
- ❌ Use complex plugins on mobile
- ❌ Store large attachments
- ❌ Use absolute file paths
- ❌ Ignore sync indicators

## 🚀 Quick Start

### Day 1: Basic Setup
- [ ] Install Obsidian on all devices
- [ ] Create vault in iCloud Drive
- [ ] Set up folder structure
- [ ] Test sync between devices

### Day 2: Integration
- [ ] Create Reminders list
- [ ] Set up Calendar events
- [ ] Install essential plugins
- [ ] Create first shortcuts

### Day 3: Optimization
- [ ] Adjust mobile settings
- [ ] Create templates
- [ ] Set up widgets
- [ ] Practice daily workflow

### Week 1: Refinement
- [ ] Identify pain points
- [ ] Adjust shortcuts
- [ ] Optimize plugins
- [ ] Establish routines

## 📚 Resources
- [Obsidian Mobile Documentation](https://help.obsidian.md/Mobile+app)
- [iOS Shortcuts Gallery](https://shortcuts.gallery)
- [Obsidian URL Scheme Docs](https://help.obsidian.md/Advanced+topics/Using+Obsidian+URI)
- [[_System/GTD Overview|GTD System Guide]]
- [[_system/pkm-guide|PKM Methodology]]

---
*The best system is the one you actually use. Start simple, optimize gradually.*