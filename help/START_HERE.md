# 🎯 START HERE

## You are 4 simple steps away from a working Snowflake MCP server

### Current Status
- ✅ You have a Snowflake account
- ✅ You have SYSADMIN and SECURITYADMIN roles
- ✅ You have this repository

### What You Need to Do

```
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: Run create_pat_token.sql in Snowsight              │
│  ├─ Click "Run All"                                         │
│  ├─ Find result with "TOKEN_SECRET" column                  │
│  └─ COPY TOKEN_SECRET immediately!                          │
│                                                              │
│  Time: 1 minute                                              │
└─────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: Run secure_pat_setup.sql in Snowsight              │
│  ├─ Click "Run All"                                         │
│  ├─ Find result with "mcp_url" column                       │
│  └─ COPY mcp_url                                            │
│                                                              │
│  Time: 1 minute                                              │
└─────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: Update ~/.cursor/mcp.json                          │
│  {                                                           │
│    "mcpServers": {                                           │
│      "Snowflake": {                                          │
│        "url": "PASTE_YOUR_MCP_URL",                         │
│        "headers": {                                          │
│          "Authorization": "Bearer PASTE_YOUR_TOKEN_SECRET"  │
│        }                                                     │
│      }                                                       │
│    }                                                         │
│  }                                                           │
│                                                              │
│  Time: 1 minute                                              │
└─────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 4: Test                                                │
│  ├─ Update verify_mcp_server.sh (lines 9-10)               │
│  ├─ Run: ./verify_mcp_server.sh                            │
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
| **create_pat_token.sql** | Create PAT token | **STEP 1** |
| **secure_pat_setup.sql** | Configure MCP access | **STEP 2** |
| verify_mcp_server.sh | Test connection | After Step 3 |
| diagnose_pat_auth.sql | Troubleshooting | If HTTP 401 error |
| secure_pat_teardown.sql | Remove everything | When cleaning up |

### Files You Can Ignore

- `README.md` - Full documentation (read later if needed)
- `help/SECURITY_COMPARISON.md` - Security details (optional)
- `LICENSE` - Apache 2.0 license
- `.cursornotes/` - Internal notes (ignored by git)

---

## 🚨 Common Mistakes to Avoid

1. ❌ **Running secure_pat_setup.sql without creating a PAT token first**
   - ✅ Run create_pat_token.sql FIRST, then secure_pat_setup.sql

2. ❌ **Forgetting to copy TOKEN_SECRET**
   - ✅ Copy it immediately when it appears (you can't retrieve it later!)

3. ❌ **Not restarting Cursor after config change**
   - ✅ Cursor loads MCP config at startup - restart required!

4. ❌ **Using the wrong URL format**
   - ✅ Use the exact URL from the script output (don't modify it)

---

## 📞 Need Help?

**HTTP 401 error?**
→ Run `diagnose_pat_auth.sql` to check grants

**HTTP 404 error?**
→ MCP server doesn't exist - check README troubleshooting section

**SSL certificate error?**
→ Using wrong URL - use exact URL from script output

**Token expired?**
→ Re-run `create_pat_token.sql` to create a new token

---

## 🎯 Ready?

**Open [`create_pat_token.sql`](../create_pat_token.sql) in Snowsight and click "Run All"!**

Then follow with [`secure_pat_setup.sql`](../secure_pat_setup.sql). Each script is simple and runs in one click. You've got this! 🚀

