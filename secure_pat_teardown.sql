/*
 * Name: secure_pat_teardown.sql
 * Synopsis: Remove MCP_ACCESS_ROLE and associated grants
 * Author: M. Whitaker
 * Created: 2025-10-21
 */

-- ###########################################################################
-- # Remove MCP Access Role
-- ###########################################################################

USE ROLE SECURITYADMIN;

-- Drop the dedicated MCP access role (CASCADE automatically revokes from users)
DROP ROLE IF EXISTS MCP_ACCESS_ROLE CASCADE;

-- ###########################################################################
-- # Note: PAT tokens are managed by the user
-- ###########################################################################

/*
To remove your PAT token manually:

1. View your tokens:
   SHOW PROGRAMMATIC ACCESS TOKENS FOR USER CURRENT_USER();

2. Drop a specific token:
   ALTER USER CURRENT_USER() DROP PROGRAMMATIC ACCESS TOKEN <token_name>;

3. Drop all tokens (use with caution):
   ALTER USER CURRENT_USER() DROP ALL PROGRAMMATIC ACCESS TOKENS;
*/

