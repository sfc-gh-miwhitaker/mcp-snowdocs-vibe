# Snowflake MCP Server Setup

**ONE secure approach. THREE simple steps. FIVE minutes.**

This repository provides a production-ready SQL script to provision a [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server that exposes Snowflake's documentation via Cortex Search to AI coding assistants (Cursor, Claude Desktop, etc.).

---

## 🚀 Quick Start (4 Steps)

### Prerequisites
- Snowflake account with `SYSADMIN` and `SECURITYADMIN` roles
- Snowflake Marketplace access (one-time `ACCOUNTADMIN` for terms acceptance)
- AI coding assistant that supports MCP (Cursor, Claude Desktop, etc.)

---

### **Step 1: Create PAT Token**

Open [`create_pat_token.sql`](create_pat_token.sql) in Snowsight.

1. Click "Run All"
2. Look for the result with "TOKEN_SECRET" column
3. **IMMEDIATELY copy the TOKEN_SECRET** value (starts with `eyJ...`)
4. **Save it in your password manager** (you'll never see it again!)

### **Step 2: Configure MCP Access**

Open [`secure_pat_setup.sql`](secure_pat_setup.sql) in Snowsight.

1. Click "Run All"
2. Look for the result with "mcp_url" column
3. **Copy the mcp_url** value

**What this script does:**
- Creates `MCP_ACCESS_ROLE` with 4 minimal privileges
- Grants role to your user
- Grants role access to MCP server
- Displays your account-specific MCP server URL

---

### **Step 3: Configure Your MCP Client**

Edit `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "Snowflake": {
      "url": "PASTE_MCP_SERVER_URL_FROM_STEP_1",
      "headers": {
        "Authorization": "Bearer PASTE_TOKEN_SECRET_FROM_STEP_1"
      }
    }
  }
}
```

For **Claude Desktop**, edit `~/Library/Application Support/Claude/claude_desktop_config.json` with the same structure.

---

### **Step 4: Test & Use**

**Test from command line:**
```bash
# Update verify_mcp_server.sh with your URL and token (lines 9-10)
./verify_mcp_server.sh
```

Expected: `✅ MCP Server: Ready and responding`

**Restart your IDE** (Cmd+Q / Alt+F4 and reopen)

**Test with a question:**
> "How do I create a dynamic table in Snowflake?"

The assistant should call the MCP server and return documentation-based answers.

---

## 🔐 Security: Minimal Privileges

The `MCP_ACCESS_ROLE` has **exactly 4 grants** and nothing more:

1. `USAGE` on `SNOWFLAKE_INTELLIGENCE` database
2. `USAGE` on `SNOWFLAKE_INTELLIGENCE.MCP` schema  
3. `USAGE` on the MCP server object
4. `IMPORTED PRIVILEGES` on `SNOWFLAKE_DOCUMENTATION` (marketplace database)

**If PAT token is compromised**, attacker can ONLY:
- ✅ Call MCP server endpoints
- ✅ Search Snowflake documentation

Attacker **CANNOT**:
- ❌ Access your data tables
- ❌ Read your schemas or databases
- ❌ Create, modify, or delete objects
- ❌ Execute arbitrary SQL queries

**Blast radius: MINIMAL** (documentation search only)

See [`help/SECURITY_COMPARISON.md`](help/SECURITY_COMPARISON.md) for detailed analysis.

---

## 📂 Project Structure

```
.
├── create_pat_token.sql        # Step 1: Create PAT token
├── secure_pat_setup.sql        # Step 2: Configure MCP access with minimal privileges  
├── secure_pat_teardown.sql     # Cleanup: Remove all MCP resources
├── verify_mcp_server.sh        # Test: Verify connection works
├── diagnose_pat_auth.sql       # Troubleshoot: Debug authorization issues
├── README.md                   # Documentation (only .md in root per project rules)
└── help/                       # Additional documentation
    ├── START_HERE.md           # Quick start visual guide
    └── SECURITY_COMPARISON.md  # Security analysis
```

---

## 🧹 Cleanup

To remove everything:

```sql
-- Execute secure_pat_teardown.sql in Snowflake
-- Drops MCP_ACCESS_ROLE and revokes all grants
```

To remove just your PAT token:

```sql
-- List your tokens
SHOW PROGRAMMATIC ACCESS TOKENS FOR USER CURRENT_USER();

-- Drop specific token
ALTER USER CURRENT_USER() DROP PROGRAMMATIC ACCESS TOKEN <token_name>;
```

---

## 🔍 Troubleshooting

### HTTP 401: Authorization Failed

**Cause:** PAT token missing required grants

**Fix:**
1. Run [`diagnose_pat_auth.sql`](diagnose_pat_auth.sql) to check grants
2. Verify `MCP_ACCESS_ROLE` exists and has 4 required grants
3. Verify role is assigned to your user
4. Re-run [`secure_pat_setup.sql`](secure_pat_setup.sql) if needed (it's idempotent)

### HTTP 404: MCP Server Not Found

**Cause:** MCP server doesn't exist or URL is wrong

**Fix:**
```sql
-- Check if server exists
USE DATABASE SNOWFLAKE_INTELLIGENCE;
USE SCHEMA MCP;
SHOW MCP SERVERS;
```

If missing, create it:
```sql
USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE DATABASE SNOWFLAKE_DOCUMENTATION 
  FROM SHARE SNO_ACCOUNT.SNO_COMMON.DOCS_SHARE;

USE ROLE SYSADMIN;
CREATE OR REPLACE MCP SERVER SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER
  AS CORTEX SEARCH SERVICE SNOWFLAKE_DOCUMENTATION.SHARED.CKE_SNOWFLAKE_DOCS_SERVICE;
```

Then run [`secure_pat_setup.sql`](secure_pat_setup.sql) again.

### SSL Certificate Error

**Cause:** Wrong URL format for your account

**Fix:** Use the exact URL from the setup script output (don't modify it)

### Token Expired

**Cause:** PAT tokens expire (default 365 days)

**Fix:**
```sql
-- Check expiry
SHOW PROGRAMMATIC ACCESS TOKENS FOR USER CURRENT_USER();

-- Create new token by re-running PHASE 1 of secure_pat_setup.sql
```

### Cursor Doesn't Show MCP Tools

**Checklist:**
- [ ] Restarted Cursor after config change?
- [ ] `~/.cursor/mcp.json` has valid JSON?
- [ ] URL and token are correct (no typos)?
- [ ] `verify_mcp_server.sh` shows HTTP 200?

---

## 📚 Additional Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [Snowflake Managed MCP Server Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-mcp)
- [Snowflake Programmatic Access Tokens](https://docs.snowflake.com/en/user-guide/authentication-using-pat)
- [Snowflake RBAC Best Practices](https://docs.snowflake.com/user-guide/security-access-control-considerations)

---

## 🤝 Contributing

Contributions welcome! Please open an issue or pull request if you find bugs or have suggestions.

## 📄 License

Apache License 2.0 - See [LICENSE](./LICENSE) file for details.

---

## 💡 Summary

**What you get:**
- ✅ Secure MCP server with minimal privileges
- ✅ Production-ready setup in 5 minutes
- ✅ Clear security boundaries
- ✅ Easy testing and validation
- ✅ Simple cleanup

**What you DON'T get:**
- ❌ Overly broad permissions
- ❌ PUBLIC role grants
- ❌ Complex multi-script setups
- ❌ Security compromises

**Start now:** See [`help/START_HERE.md`](help/START_HERE.md) for a visual guide, or open [`secure_pat_setup.sql`](secure_pat_setup.sql) directly! 🚀
