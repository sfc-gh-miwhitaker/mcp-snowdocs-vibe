/*
 * Name: create_token.sql
 * Synopsis: Create a Programmatic Access Token (PAT) for MCP server authentication
 * Author: M. Whitaker
 * Created: 2025-10-21
 * Updated: 2025-10-22 (renamed from create_pat_token.sql)
 * 
 * HOW TO RUN:
 * 1. Click "Run All" in Snowsight
 * 2. Look at the output panel for the result with "TOKEN_SECRET" column
 * 3. COPY the TOKEN_SECRET value immediately (starts with eyJ...)
 * 4. Save it in your password manager - you cannot retrieve it later!
 * 
 * This token will have your current role's permissions.
 * After creating the token, run setup_mcp.sql to configure MCP access.
 */

-- Get current user name
SET session_user_name = (SELECT CURRENT_USER());

-- Generate unique token name with timestamp
SET token_name = 'MCP_PAT_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDD_HH24MISS');

-- Create PAT token
-- ⚠️  The result will contain TOKEN_SECRET - COPY IT IMMEDIATELY!
ALTER USER IDENTIFIER($session_user_name) ADD PROGRAMMATIC ACCESS TOKEN IDENTIFIER($token_name)
  DAYS_TO_EXPIRY = 365
  COMMENT = 'MCP server authentication token';

/*
NEXT STEPS:
1. ✅ Copy the TOKEN_SECRET from the result above
2. ✅ Save it in your password manager
3. Run setup_mcp.sql to configure MCP server access
4. Use the TOKEN_SECRET in your MCP client configuration
*/

