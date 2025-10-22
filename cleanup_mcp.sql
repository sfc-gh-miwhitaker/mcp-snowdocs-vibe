/*
 * Name: cleanup_mcp.sql
 * Synopsis: Clean up MCP server and role while preserving reusable infrastructure
 * Author: M. Whitaker
 * Created: 2025-10-21
 * Updated: 2025-10-22 (renamed from secure_pat_teardown.sql)
 * 
 * PURPOSE:
 * This script removes resources created by setup_mcp.sql while preserving:
 * - PAT tokens (user may need them for other purposes)
 * - SNOWFLAKE_INTELLIGENCE database (shared across multiple examples)
 * - SNOWFLAKE_INTELLIGENCE schemas (TOOLS, AGENTS, MCP - reusable infrastructure)
 * - SNOWFLAKE_DOCUMENTATION database (imported share, may be used elsewhere)
 * 
 * WHAT GETS REMOVED:
 * - MCP server: SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER
 * - Role: MCP_ACCESS_ROLE (and all grants)
 * 
 * WHAT GETS PRESERVED:
 * - Database: SNOWFLAKE_INTELLIGENCE (and all schemas)
 * - Database: SNOWFLAKE_DOCUMENTATION (imported share)
 * - PAT tokens (managed separately by user)
 * 
 * HOW TO RUN:
 * 1. Click "Run All" in Snowsight
 * 2. Verify completion with the final verification step
 */

-- ###########################################################################
-- # STEP 1: Drop MCP Server
-- ###########################################################################

USE ROLE SYSADMIN;

-- Drop the MCP server (this is the main resource we want to clean up)
-- This automatically removes all grants on the MCP server
DROP MCP SERVER IF EXISTS SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER;

-- Verify MCP server is removed
SHOW MCP SERVERS IN SCHEMA SNOWFLAKE_INTELLIGENCE.MCP;

-- ###########################################################################
-- # STEP 2: Drop MCP Access Role
-- ###########################################################################

USE ROLE SECURITYADMIN;

-- Drop the dedicated MCP access role
-- CASCADE automatically:
-- - Revokes role from all users
-- - Removes all grants TO this role
-- - Removes all grants OF this role to other roles
DROP ROLE IF EXISTS MCP_ACCESS_ROLE CASCADE;

-- Verify role is removed
SHOW ROLES LIKE 'MCP_ACCESS_ROLE';

-- ###########################################################################
-- # VERIFICATION: What Remains
-- ###########################################################################

USE ROLE SYSADMIN;

-- Verify SNOWFLAKE_INTELLIGENCE database still exists (PRESERVED)
SHOW DATABASES LIKE 'SNOWFLAKE_INTELLIGENCE';

-- Verify SNOWFLAKE_INTELLIGENCE.MCP schema still exists (PRESERVED)
SHOW SCHEMAS IN DATABASE SNOWFLAKE_INTELLIGENCE;

-- Verify SNOWFLAKE_DOCUMENTATION database still exists (PRESERVED)
SHOW DATABASES LIKE 'SNOWFLAKE_DOCUMENTATION';

-- Verify your PAT tokens still exist (PRESERVED)
-- Note: Replace CURRENT_USER() with your actual username if this fails
SHOW PROGRAMMATIC ACCESS TOKENS;

-- ###########################################################################
-- # OPTIONAL: Manual PAT Token Cleanup
-- ###########################################################################

/*
PAT TOKENS ARE PRESERVED BY DEFAULT

If you want to remove PAT tokens manually (use with caution):

1. View your tokens:
   SHOW PROGRAMMATIC ACCESS TOKENS;

2. Drop a specific token by name:
   SET token_to_drop = 'MCP_PAT_20251021_123456';
   ALTER USER CURRENT_USER() DROP PROGRAMMATIC ACCESS TOKEN IDENTIFIER($token_to_drop);

3. Drop all tokens (DANGEROUS - use only if certain):
   ALTER USER CURRENT_USER() DROP ALL PROGRAMMATIC ACCESS TOKENS;

NOTE: Dropping tokens will break any applications using them!
*/

-- ###########################################################################
-- # CLEANUP SUMMARY
-- ###########################################################################

/*
WHAT WAS REMOVED:
=================
✅ MCP Server: SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER
✅ Role: MCP_ACCESS_ROLE (and all associated grants)

WHAT WAS PRESERVED:
===================
✅ Database: SNOWFLAKE_INTELLIGENCE (reusable for other examples)
✅ Schema: SNOWFLAKE_INTELLIGENCE.MCP (reusable infrastructure)
✅ Schema: SNOWFLAKE_INTELLIGENCE.TOOLS (if exists, reusable)
✅ Schema: SNOWFLAKE_INTELLIGENCE.AGENTS (if exists, reusable)
✅ Database: SNOWFLAKE_DOCUMENTATION (imported share, may be used elsewhere)
✅ PAT Tokens: All tokens remain active (user-managed)

TO VERIFY CLEANUP:
==================
1. MCP server should NOT appear in: SHOW MCP SERVERS
2. MCP_ACCESS_ROLE should NOT appear in: SHOW ROLES
3. SNOWFLAKE_INTELLIGENCE database SHOULD still exist
4. PAT tokens SHOULD still be listed

TO RECREATE:
============
Run setup_mcp.sql to recreate the MCP server and role.
Your existing PAT token can be reused (if not expired).
*/

