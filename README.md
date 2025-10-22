# Snowflake MCP Server Setup

**ONE secure approach. THREE simple steps. FIVE minutes.**

This repository provides a production-ready SQL script to provision a [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server that exposes Snowflake's documentation via Cortex Search to AI coding assistants like **Cursor**, **Claude Desktop**, **VS Code**, and other MCP-compatible IDEs.

---

> 👋 **First time here?** Follow these 3 files in order:
> 1. [`create_token.sql`](create_token.sql) - Creates your access token (1 min)
> 2. [`setup_mcp.sql`](setup_mcp.sql) - Configures MCP server (1 min)
> 3. [`test_connection.sh`](test_connection.sh) - Verifies everything works (1 min)
> 
> Each file has instructions inside. Takes 5 minutes total.
> 
> **Or** see [`help/GETTING_STARTED.md`](help/GETTING_STARTED.md) for a visual step-by-step guide.

---

## 🚀 Quick Start

### Prerequisites
- Snowflake account with `SYSADMIN` and `SECURITYADMIN` roles
- Snowflake Marketplace access (one-time `ACCOUNTADMIN` for terms acceptance)
- MCP-compatible IDE: **Cursor**, **Claude Desktop**, **VS Code** (with Continue.dev), **Zed**, or [others](https://modelcontextprotocol.io/implementations)

---

### **Step 1: Create Token**

Open [`create_token.sql`](create_token.sql) in Snowsight.

1. Click "Run All"
2. Look for the result with "TOKEN_SECRET" column
3. **IMMEDIATELY copy the TOKEN_SECRET** value (starts with `eyJ...`)
4. **Save it in your password manager** (you'll never see it again!)

### **Step 2: Setup MCP Server**

Open [`setup_mcp.sql`](setup_mcp.sql) in Snowsight.

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

Choose your IDE and follow the configuration below:

<details>
<summary><b>Cursor</b> (Click to expand)</summary>

Edit `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "Snowflake": {
      "url": "PASTE_MCP_SERVER_URL_FROM_STEP_2",
      "headers": {
        "Authorization": "Bearer PASTE_TOKEN_SECRET_FROM_STEP_1"
      }
    }
  }
}
```

**Location by OS:**
- **macOS/Linux**: `~/.cursor/mcp.json`
- **Windows**: `%USERPROFILE%\.cursor\mcp.json`

**After editing:**
1. Save the file
2. Restart Cursor (Cmd+Q on Mac, Alt+F4 on Windows)
3. The Snowflake MCP server will be available in the Composer

</details>

<details>
<summary><b>Claude Desktop</b> (Click to expand)</summary>

Edit Claude Desktop's configuration file:

```json
{
  "mcpServers": {
    "Snowflake": {
      "url": "PASTE_MCP_SERVER_URL_FROM_STEP_2",
      "headers": {
        "Authorization": "Bearer PASTE_TOKEN_SECRET_FROM_STEP_1"
      }
    }
  }
}
```

**Location by OS:**
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

**After editing:**
1. Save the file
2. Restart Claude Desktop
3. Look for the 🔨 (hammer) icon in the chat - it indicates MCP tools are available

</details>

<details>
<summary><b>VS Code (with Continue.dev extension)</b> (Click to expand)</summary>

**VS Code supports MCP through the Continue.dev extension:**

1. **Install Continue.dev extension** from VS Code marketplace
2. **Edit your Continue configuration** at `~/.continue/config.json`:

```json
{
  "mcpServers": {
    "snowflake": {
      "url": "PASTE_MCP_SERVER_URL_FROM_STEP_2",
      "headers": {
        "Authorization": "Bearer PASTE_TOKEN_SECRET_FROM_STEP_1"
      }
    }
  }
}
```

**Location by OS:**
- **macOS/Linux**: `~/.continue/config.json`
- **Windows**: `%USERPROFILE%\.continue\config.json`

**After editing:**
1. Save the file
2. Reload VS Code window (Cmd+Shift+P → "Developer: Reload Window")
3. Open Continue panel (Cmd+L or Ctrl+L)
4. The Snowflake MCP server will be available in Continue's context menu

**Note**: Continue.dev has broader MCP support than native VS Code. For latest setup instructions, see [Continue.dev documentation](https://docs.continue.dev/).

</details>

<details>
<summary><b>Other MCP-Compatible IDEs</b> (Click to expand)</summary>

Any IDE that supports the [Model Context Protocol](https://modelcontextprotocol.io/) can use this server:

**Configuration Pattern:**
```json
{
  "mcpServers": {
    "Snowflake": {
      "url": "YOUR_MCP_SERVER_URL",
      "headers": {
        "Authorization": "Bearer YOUR_TOKEN_SECRET"
      }
    }
  }
}
```

**Supported IDEs:**
- ✅ Cursor
- ✅ Claude Desktop
- ✅ VS Code (via Continue.dev extension)
- ✅ Zed (with MCP extension)
- 🔄 Others (check [MCP implementation list](https://modelcontextprotocol.io/implementations))

</details>

---

### **Step 4: Test & Use**

**Test from command line:**
```bash
# Update test_connection.sh with your URL and token (lines 11-12)
./test_connection.sh
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

See [`help/SECURITY.md`](help/SECURITY.md) for detailed analysis.

---

## 📂 Project Structure

```
.
├── create_token.sql            # Step 1: Create access token (simplified naming)
├── setup_mcp.sql               # Step 2: Configure MCP server with minimal privileges
├── cleanup_mcp.sql             # Cleanup: Remove MCP resources (preserves infrastructure)
├── test_connection.sh          # Test: Verify connection works
├── troubleshoot.sql            # Troubleshoot: Debug authorization issues
├── README.md                   # Main documentation
└── help/                       # Additional documentation
    ├── GETTING_STARTED.md      # Visual step-by-step guide for beginners
    └── SECURITY.md             # Security analysis and best practices
```

---

## 🧹 Cleanup

To remove MCP server and role (preserves reusable infrastructure):

```sql
-- Execute cleanup_mcp.sql in Snowsight
-- Removes:
--   - MCP server (SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER)
--   - MCP_ACCESS_ROLE and all grants
-- Preserves:
--   - SNOWFLAKE_INTELLIGENCE database and schemas (reusable)
--   - SNOWFLAKE_DOCUMENTATION database (may be used by other examples)
--   - PAT tokens (user-managed, may be used elsewhere)
```

**What Gets Cleaned Up:**
- ✅ MCP server object
- ✅ MCP_ACCESS_ROLE (automatically revoked from users)

**What Stays (Reusable Infrastructure):**
- ✅ SNOWFLAKE_INTELLIGENCE database (shared across examples)
- ✅ SNOWFLAKE_INTELLIGENCE.MCP schema (reusable)
- ✅ SNOWFLAKE_DOCUMENTATION database (imported share)
- ✅ PAT tokens (may be needed for other purposes)

To remove your PAT token manually (optional):

```sql
-- List your tokens
SHOW PROGRAMMATIC ACCESS TOKENS;

-- Drop specific token
ALTER USER CURRENT_USER() DROP PROGRAMMATIC ACCESS TOKEN <token_name>;
```

**Note:** PAT tokens are intentionally preserved because they may be used for other Snowflake integrations or examples.

---

## 🔍 Troubleshooting

### HTTP 401: Authorization Failed

**Cause:** PAT token missing required grants

**Fix:**
1. Run [`troubleshoot.sql`](troubleshoot.sql) to check grants
2. Verify `MCP_ACCESS_ROLE` exists and has 4 required grants
3. Verify role is assigned to your user
4. Re-run [`setup_mcp.sql`](setup_mcp.sql) if needed (it's idempotent)

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

Then run [`setup_mcp.sql`](setup_mcp.sql) again.

### SSL Certificate Error

**Cause:** Wrong URL format for your account

**Fix:** Use the exact URL from the setup script output (don't modify it)

### Token Expired

**Cause:** PAT tokens expire (default 365 days)

**Fix:**
```sql
-- Check expiry
SHOW PROGRAMMATIC ACCESS TOKENS;

-- Create new token by re-running create_token.sql
```

### IDE Doesn't Show MCP Tools

**For Cursor:**
- [ ] Restarted Cursor after config change?
- [ ] `~/.cursor/mcp.json` has valid JSON?
- [ ] URL and token are correct (no typos)?
- [ ] Check Cursor's MCP status in settings

**For Claude Desktop:**
- [ ] Restarted Claude Desktop after config change?
- [ ] Config file path correct for your OS?
- [ ] Look for 🔨 (hammer) icon in new chats
- [ ] Check Claude Desktop logs: `~/Library/Logs/Claude/` (macOS)

**For VS Code (Continue.dev):**
- [ ] Continue.dev extension installed and enabled?
- [ ] Reloaded VS Code window after config change?
- [ ] Config file at `~/.continue/config.json`?
- [ ] Open Continue panel (Cmd+L / Ctrl+L) to verify

**For All IDEs:**
- [ ] `test_connection.sh` shows HTTP 200?
- [ ] Token hasn't expired (default: 365 days)?
- [ ] MCP server URL uses lowercase format?

---

## 🔄 IDE Compatibility Matrix

| Feature | Cursor | Claude Desktop | VS Code + Continue | Zed |
|---------|--------|----------------|-------------------|-----|
| **MCP Support** | ✅ Native | ✅ Native | ✅ Extension | ✅ Extension |
| **Setup Complexity** | Easy | Easy | Medium | Medium |
| **Snowflake Docs Access** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Real-time Search** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Configuration File** | `~/.cursor/mcp.json` | OS-specific | `~/.continue/config.json` | Plugin config |
| **Visual Indicator** | Composer tools | 🔨 icon | Continue panel (Cmd+L) | Status bar |
| **Our Testing Status** | ✅ Verified | ✅ Verified | ⚠️ Community | ⚠️ Community |

**Legend:**
- ✅ Fully supported and tested
- ⚠️ Supported but not extensively tested by us
- 🔄 Planned/In development
- ❌ Not supported

---

## 📚 Additional Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [MCP Implementation List](https://modelcontextprotocol.io/implementations) - See all compatible IDEs
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

**Start now:** See [`help/GETTING_STARTED.md`](help/GETTING_STARTED.md) for a visual guide, or open [`create_token.sql`](create_token.sql) to begin! 🚀
