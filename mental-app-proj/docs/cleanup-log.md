# Branch Cleanup Log

## Branch Comparison: static-deployment vs pre-qa-v1
**Date:** 2025-08-06  
**Purpose:** Determine the latest good base branch to use as single source of truth

---

## Analysis Results

### mental-coach-api Repository

#### Branch: `static-deployment`
- **Commit:** f7d6098
- **Date:** 2025-08-06 19:47:18 +0300
- **Message:** feat: create static deployment branch with NIXPACKS

#### Branch: `pre-qa-v1`
- **Commit:** 4ed2e23
- **Date:** 2025-08-06 19:36:31 +0300
- **Message:** feat: comprehensive project reorganization and documentation overhaul

**🎯 Latest Base:** `static-deployment` (newer by ~11 minutes)

---

### mental-coach-admin Repository

#### Branch: `static-deployment`
- **Commit:** aa313c2
- **Date:** 2025-08-06 19:49:03 +0300
- **Message:** feat: create static deployment branch for admin panel

#### Branch: `pre-qa-v1`
- **Commit:** 370ae0b
- **Date:** 2025-08-06 18:27:51 +0300
- **Message:** feat: add Railway deployment configuration and user dialog fixes

**🎯 Latest Base:** `static-deployment` (newer by ~1 hour 21 minutes)

---

### mental-coach-flutter Repository

#### Branch: `static-deployment`
- **Commit:** a62fa9a
- **Date:** 2025-08-06 20:34:04 +0300
- **Message:** trigger: Railway deployment

#### Branch: `pre-qa-v1`
- **Commit:** 0f36a6b
- **Date:** 2025-08-06 19:22:20 +0300
- **Message:** fix(config): use dev environment for Railway deployment

**🎯 Latest Base:** `static-deployment` (newer by ~1 hour 12 minutes)

---

## Conclusion

✅ **Decision: `static-deployment` branch is the latest base across ALL repositories**

The `static-deployment` branch is consistently newer than `pre-qa-v1` in all three repositories:
- **mental-coach-api:** static-deployment is 11 minutes newer
- **mental-coach-admin:** static-deployment is 1 hour 21 minutes newer  
- **mental-coach-flutter:** static-deployment is 1 hour 12 minutes newer

**Recommendation:** Use `static-deployment` as the single source of truth for the cleanup process.

---

## Next Steps
- [ ] Use `static-deployment` as the base branch for cleanup
- [ ] Merge or rebase other branches against `static-deployment`
- [ ] Remove obsolete branches that have been merged into `static-deployment`
