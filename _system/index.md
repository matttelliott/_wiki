---
created: 2025-08-18
modified: 2025-08-18
type: index
tags: [dashboard, home]
---

# 🏠 Personal Knowledge System Dashboard

## 🚀 Quick Access
### Daily Operations
- [[04-daily/{{date:YYYY-MM-DD}}|Today's Daily Note]]
- [[00-inbox/|📥 Inbox]] - Process captured items
- [[05-templates/weekly-review|📅 Weekly Review Template]]

### Quick Capture
- [[05-templates/idea-capture|💡 New Idea]]
- [[05-templates/meeting-note|👥 New Meeting]]
- [[05-templates/project|📋 New Project]]

## 📊 GTD System
### Collection Points
- **[[00-inbox]]** - All captured items for processing
- **Apple Reminders** - Quick capture on iOS/macOS
- **Physical Inbox** - Papers and materials

### Horizons of Focus
1. **Runway** - [[Next Actions|Current Actions]]
2. **Projects** - [[01-projects/_active|Active Projects]]
3. **Areas** - [[02-areas|Areas of Responsibility]]
4. **Goals** - [[Annual Goals|1-2 Year Objectives]]
5. **Vision** - [[Vision|3-5 Year Vision]]
6. **Purpose** - [[Life Purpose|Purpose & Principles]]

### Contexts
- #@home - Tasks to do at home
- #@work - Tasks for work/office
- #@computer - Computer-required tasks
- #@phone - Calls and phone tasks
- #@errands - Out and about tasks
- #@anywhere - Tasks doable anywhere

## 🗂 Knowledge Management

### Areas of Focus
- [[02-Areas/Personal|👤 Personal Development]]
- [[02-Areas/Professional|💼 Professional Growth]]
- [[02-Areas/Learning|📚 Learning & Education]]

### Resources & References
- [[03-Resources/Literature|📖 Literature Library]]
- [[03-Resources/References|📑 Reference Materials]]
- [[03-Resources/Archives|🗄 Archives]]

## 🎯 Current Focus

### Active Projects (Top 5)
```dataview
TABLE status, due, priority
FROM "01-Projects/_Active"
WHERE type = "project"
SORT priority DESC, due ASC
LIMIT 5
```

### Today's Tasks
```dataview
TASK
WHERE !completed AND text != ""
WHERE contains(text, "^due(" + this.date + ")")
SORT priority DESC
```

### Waiting For
```dataview
TASK
WHERE !completed
WHERE contains(text, "#waiting")
```

## 📈 Weekly Stats
- **Notes Created This Week:** `$= dv.pages('"04-Daily"').where(p => p.created >= dv.date("today").minus({days: 7})).length`
- **Projects Completed:** `$= dv.pages('"01-Projects/_Completed"').where(p => p.modified >= dv.date("today").minus({days: 7})).length`
- **Active Projects:** `$= dv.pages('"01-Projects/_Active"').where(p => p.status == "active").length`

## 🔧 System Management

### Documentation
- [[_system/gtd-overview|GTD System Guide]]
- [[_system/pkm-guide|PKM Methodology]]
- [[_system/apple-integration|Apple Ecosystem Setup]]
- [[_system/readme|Quick Start Guide]]

### Templates
- [[05-templates/daily-note|Daily Note Template]]
- [[05-templates/weekly-review|Weekly Review Template]]
- [[05-templates/project|Project Template]]
- [[05-templates/literature-note|Literature Note Template]]
- [[05-templates/idea-capture|Idea Capture Template]]
- [[05-templates/meeting-note|Meeting Note Template]]

### Maintenance
- [ ] Weekly Review - Every Sunday
- [ ] Monthly Area Review - First Sunday
- [ ] Quarterly Goal Review - First week of quarter
- [ ] Annual Vision Review - December

## 🔗 External Links
- [Obsidian Documentation](https://help.obsidian.md)
- [GTD Methodology](https://gettingthingsdone.com)
- [Zettelkasten Method](https://zettelkasten.de)

---
*Last Dashboard Update: 2025-08-18*