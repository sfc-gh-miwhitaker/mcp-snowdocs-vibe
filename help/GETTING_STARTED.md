# 🎯 Getting Started

## You are 3 simple steps away from a working Snowflake MCP server

### Current Status
- ✅ You have a Snowflake account
- ✅ You have SYSADMIN and SECURITYADMIN roles
- ✅ You have this repository

### What You Need to Do

```
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: Run create_token.sql in Snowsight                  │
│  ├─ Click "Run All"                                         │
│  ├─ Find result with "TOKEN_SECRET" column                  │
│  └─ COPY TOKEN_SECRET immediately!                          │
│                                                              │
│  Time: 1 minute                                              │
└─────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: Run setup_mcp.sql in Snowsight                     │
│  ├─ Click "Run All"                                         │
│  ├─ Find result with "mcp_url" column                       │
│  └─ COPY mcp_url                                            │
│                                                              │
│  Time: 1 minute                                              │
└─────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: Update ~/.cursor/mcp.json and test                 │
│  ├─ Edit config with your URL and token                     │
│  ├─ Optional: Run ./test_connection.sh to verify            │
│  ├─ Restart Cursor (Cmd+Q)                                  │
│  └─ Ask: "How do I create a dynamic table in Snowflake?"   │
│                                                              │
│  Time: 2 minutes                                             │
└─────────────────────────────────────────────────────────────┘
                             ↓
                          ✅ DONE!
```

### Files You Need

| File | Purpose | When to Use |
|------|---------|-------------|
| **create_token.sql** | Create access token | **STEP 1** |
| **setup_mcp.sql** | Configure MCP server | **STEP 2** |
| test_connection.sh | Test connection | After Step 2 (optional) |
| troubleshoot.sql | Troubleshooting | If HTTP 401 error |
| cleanup_mcp.sql | Remove MCP resources | When cleaning up (preserves infrastructure) |

### Files You Can Ignore

- `README.md` - Full documentation (read later if needed)
- `help/SECURITY.md` - Security details (optional)
- `LICENSE` - Apache 2.0 license
- `CHANGELOG.md` - Version history
- `.cursornotes/` - Internal notes (ignored by git)

---

## 🚨 Common Mistakes to Avoid

1. ❌ **Running setup_mcp.sql without creating a token first**
   - ✅ Run create_token.sql FIRST, then setup_mcp.sql

2. ❌ **Forgetting to copy TOKEN_SECRET**
   - ✅ Copy it immediately when it appears (you can't retrieve it later!)

3. ❌ **Not restarting Cursor after config change**
   - ✅ Cursor loads MCP config at startup - restart required!

4. ❌ **Using the wrong URL format**
   - ✅ Use the exact URL from the script output (don't modify it)

---

## 📞 Need Help?

**HTTP 401 error?**
→ Run `troubleshoot.sql` to check grants

**HTTP 404 error?**
→ MCP server doesn't exist - check README troubleshooting section

**SSL certificate error?**
→ Using wrong URL - use exact URL from script output

**Token expired?**
→ Re-run `create_token.sql` to create a new token

---

## 🎯 Ready?

**Open [`create_token.sql`](../create_token.sql) in Snowsight and click "Run All"!**

Then follow with [`setup_mcp.sql`](../setup_mcp.sql). Each script is simple and runs in one click. You've got this! 🚀

