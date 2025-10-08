# Snowflake MCP Server Setup

This repository provides a turnkey SQL script to provision a [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server that exposes Snowflake's documentation via Cortex Search to AI coding assistants.

## What This Script Does

1. **Mounts the Snowflake Documentation** from the Snowflake Marketplace as a Cortex Knowledge Extension (CKE)
2. **Creates two roles**:
   - `SNOWFLAKE_MCP_APP_ROLE` – Administrative role for managing MCP infrastructure
   - `SNOWFLAKE_MCP_USER_ROLE` – Read-only consumer role for end users
3. **Provisions a managed MCP server** in the `SNOWFLAKE_INTELLIGENCE.MCP` schema
4. **Issues a programmatic access token (PAT)** for the current user
5. **Creates a helper view** with ready-to-use connection strings for Cursor, Claude Desktop, and GitHub Copilot

## Prerequisites

- Snowflake account with `SYSADMIN` and `SECURITYADMIN` roles granted to your user
- One-time `ACCOUNTADMIN` access to accept the Snowflake Documentation marketplace listing (the script handles this automatically)
- Access to the Snowflake Marketplace
- An AI coding assistant that supports MCP servers (Cursor, Claude Desktop, etc.)

## Usage

### 1. Run the Setup Script

Execute [`setup_snowflake_mcp.sql`](./setup_snowflake_mcp.sql) in your Snowflake account using Snowsight, SnowSQL, or any SQL client:

```sql
-- In Snowsight: paste the entire script and click "Run"
```

The script will:
- Accept marketplace terms and create the `SNOWFLAKE_DOCUMENTATION` database
- Provision the `SNOWFLAKE_MCP_SERVER` object
- Output a table with MCP client configuration parameters

### 2. Capture Your PAT Token

The `ALTER USER ... ADD PROGRAMMATIC ACCESS TOKEN` statement returns a `token_secret` column. **This is the only time Snowflake displays the secret.** Copy it immediately and store it securely (e.g., in a password manager or secrets vault).

### 3. Configure Your AI Client

Query the helper view to get your account-specific connection details:

```sql
SELECT * FROM SNOWFLAKE_INTELLIGENCE.TOOLS.SNOWFLAKE_MCP_CLIENT_CONFIGS;
```

Copy the `url` and `header_value` (paste your PAT token secret in place of the placeholder) into your client's MCP configuration file. Examples:

#### Cursor (`~/.cursor/mcp.json`)

```json
{
  "mcpServers": {
    "Snowflake": {
      "url": "https://<account>.<region>.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/tools/mcp-servers/snowflake_mcp_server",
      "headers": {
        "Authorization": "Bearer <YOUR_PAT_TOKEN_SECRET>"
      }
    }
  }
}
```

#### Claude Desktop (`~/Library/Application Support/Claude/claude_desktop_config.json`)

```json
{
  "mcpServers": {
    "snowflake-docs": {
      "type": "http",
      "url": "https://<account>.<region>.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/tools/mcp-servers/snowflake_mcp_server",
      "headers": {
        "Authorization": "Bearer <YOUR_PAT_TOKEN_SECRET>"
      }
    }
  }
}
```

Restart your AI assistant to load the new MCP server.

### 4. Test the Connection

Ask your AI assistant a Snowflake question, such as:

> "How do I create a dynamic table in Snowflake?"

The assistant should invoke the `snowflake-docs-search` tool and return an answer citing the official Snowflake documentation.

## Security Considerations

- **Role-Based Approach**: This script follows Snowflake's recommended RBAC pattern:
  - `ACCOUNTADMIN` is used **only** for the one-time marketplace terms acceptance
  - `SECURITYADMIN` manages role creation and grants
  - `SYSADMIN` manages database and schema objects
  - This separation of duties is a production-ready pattern
- **PAT Expiry**: The default 365-day expiry is suitable for long-running demos and workshops
- **Token Storage**: Treat PAT secrets like passwords. Never commit them to version control or share them in plain text
- **Shared Database**: The script uses `IF NOT EXISTS` for `SNOWFLAKE_INTELLIGENCE` to avoid disrupting existing AI/ML workloads in multi-tenant environments

## Troubleshooting

### "Object does not exist" when querying the view
Ensure you're using the fully qualified name:
```sql
SELECT * FROM SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_CLIENT_CONFIGS;
```

### "Insufficient privileges" error
Ensure your user has both `SYSADMIN` and `SECURITYADMIN` roles granted:
```sql
-- Run as ACCOUNTADMIN to grant required roles
GRANT ROLE SYSADMIN TO USER <your_username>;
GRANT ROLE SECURITYADMIN TO USER <your_username>;
```

### MCP server not appearing in your AI client
1. Verify the URL matches the output of the helper view
2. Confirm the PAT token secret is correct (no extra spaces or quotes)
3. Restart your AI assistant to reload the MCP configuration

## Contributing

Contributions are welcome! Please open an issue or pull request if you find bugs or have suggestions for improvements.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](./LICENSE) file for details.

## Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [Snowflake Managed MCP Server Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-mcp)
- [Snowflake Programmatic Access Tokens](https://docs.snowflake.com/en/user-guide/authentication-using-pat)

