# Security Comparison: PUBLIC Role vs. Dedicated Role

## The Problem with PUBLIC Role

When you create a PAT token while using `PUBLIC` role, the token inherits **all privileges granted to PUBLIC**, which typically includes:

- ❌ Access to all objects granted to PUBLIC (potentially many databases/schemas)
- ❌ Cannot be revoked without affecting all users
- ❌ Difficult to audit (PUBLIC is used by everyone)
- ❌ Principle of least privilege violated
- ❌ If token is compromised, attacker has broad access

## The Secure Approach: Dedicated Role

Create a **dedicated role** (`MCP_ACCESS_ROLE`) with **ONLY** the minimal privileges needed for MCP server access.

### Exact Privileges Required

Based on Snowflake documentation and testing, the MCP server requires exactly:

| Privilege | Object | Reason |
|-----------|--------|--------|
| `USAGE` | `SNOWFLAKE_INTELLIGENCE` database | Access to MCP server database |
| `USAGE` | `SNOWFLAKE_INTELLIGENCE.MCP` schema | Access to MCP server schema |
| `USAGE` | `SNOWFLAKE_MCP_SERVER` object | Call MCP server API endpoints |
| `IMPORTED PRIVILEGES` | `SNOWFLAKE_DOCUMENTATION` database | Access to underlying Cortex Search Service |

**That's it!** No other privileges needed.

### Security Benefits

| Feature | PUBLIC Role | MCP_ACCESS_ROLE |
|---------|-------------|-----------------|
| **Scope** | All PUBLIC grants (potentially broad) | Only 4 specific grants |
| **Revocability** | Affects all users | Only affects MCP access |
| **Auditability** | Hard to trace | Clear audit trail |
| **Blast Radius** | Large (if token compromised) | Minimal (only MCP endpoints) |
| **Compliance** | ❌ Fails least privilege | ✅ Meets least privilege |

## Implementation

### Step 1: Create Secure Setup

Run [`setup_mcp.sql`](../setup_mcp.sql):

```sql
-- Creates MCP_ACCESS_ROLE with minimal privileges
-- Assigns role to your user
-- Creates PAT token scoped to MCP_ACCESS_ROLE
-- Verifies setup works
```

### Step 2: Copy Token

The script output will show:
```
TOKEN_SECRET: eyJ... (copy this!)
```

**Copy it immediately** - it's only shown once.

### Step 3: Configure Client

Update your `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "Snowflake": {
      "url": "https://...",
      "headers": {
        "Authorization": "Bearer <paste_token_here>"
      }
    }
  }
}
```

### Step 4: Verify

Run [`test_connection.sh`](../test_connection.sh):

```bash
./test_connection.sh
```

Should see: `✅ MCP Server: Ready and responding`

## Cleanup

If you previously used PUBLIC role approach, you can remove those grants:

```sql
-- Remove PUBLIC grants (run as SYSADMIN)
REVOKE USAGE ON MCP SERVER SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER 
  FROM ROLE PUBLIC;
REVOKE USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE FROM ROLE PUBLIC;
REVOKE USAGE ON SCHEMA SNOWFLAKE_INTELLIGENCE.MCP FROM ROLE PUBLIC;
REVOKE IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_DOCUMENTATION FROM ROLE PUBLIC;
```

To remove the MCP setup:

```sql
-- Run cleanup_mcp.sql in Snowsight
-- This removes:
--   - MCP server (SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER)
--   - MCP_ACCESS_ROLE (automatically revokes from users)
-- This preserves:
--   - SNOWFLAKE_INTELLIGENCE database and schemas (reusable)
--   - SNOWFLAKE_DOCUMENTATION database (may be used by other examples)
--   - PAT tokens (user-managed, may be needed elsewhere)
```

## Recommendation

**✅ Use `MCP_ACCESS_ROLE` approach** for:
- Production environments
- Security-conscious deployments
- Compliance requirements (SOC2, HIPAA, etc.)
- Multi-user accounts

**❓ PUBLIC role might be acceptable for:**
- Personal sandbox accounts
- Temporary testing (delete token after)
- Accounts where PUBLIC already has broad access

## Summary

The **secure approach** provides:

1. ✅ **Minimal privileges** - only what MCP server needs
2. ✅ **Clear audit trail** - all access via MCP_ACCESS_ROLE
3. ✅ **Easy revocation** - drop role or revoke from user
4. ✅ **Compliance ready** - meets least privilege principle
5. ✅ **Small blast radius** - compromised token has limited access

**Use [`setup_mcp.sql`](../setup_mcp.sql) for production deployments.**

