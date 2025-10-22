/*
 * Name: troubleshoot.sql
 * Synopsis: Comprehensive diagnostics for PAT token authorization issues
 * Author: M. Whitaker
 * Created: 2025-10-21
 * Updated: 2025-10-22 (renamed from diagnose_pat_auth.sql)
 * 
 * PURPOSE:
 * This script helps diagnose MCP server authentication issues by checking:
 * - MCP server existence and grants
 * - Role-based access control configuration
 * - Cortex Search Service dependencies
 * - PAT token configuration
 * 
 * HOW TO RUN:
 * 1. Click "Run All" in Snowsight
 * 2. Review each result set sequentially
 * 3. Look for errors or missing grants indicated in comments
 * 4. If issues found, re-run setup_mcp.sql or cleanup_mcp.sql
 * 
 * EXPECTED BEHAVIOR:
 * - All queries should succeed (no SQL errors)
 * - You should see grants for MCP_ACCESS_ROLE in multiple steps
 * - Your user should have MCP_ACCESS_ROLE assigned
 * - At least one PAT token should appear in Step 7
 */

-- ###########################################################################
-- # STEP 1: Check MCP Server Existence and Grants
-- ###########################################################################

USE ROLE SYSADMIN;

-- Check MCP server existence
-- EXPECTED: Should show SNOWFLAKE_MCP_SERVER
SHOW MCP SERVERS IN SCHEMA SNOWFLAKE_INTELLIGENCE.MCP;

-- Check grants on MCP server
-- EXPECTED: Should show USAGE grant to MCP_ACCESS_ROLE
SHOW GRANTS ON MCP SERVER SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER;

-- ###########################################################################
-- # STEP 2: Check MCP_ACCESS_ROLE Grants
-- ###########################################################################

-- Check MCP_ACCESS_ROLE grants
-- EXPECTED: Should show 4 grants:
--   1. USAGE on SNOWFLAKE_INTELLIGENCE
--   2. USAGE on SNOWFLAKE_INTELLIGENCE.MCP
--   3. USAGE on MCP SERVER SNOWFLAKE_MCP_SERVER
--   4. IMPORTED PRIVILEGES on SNOWFLAKE_DOCUMENTATION
SHOW GRANTS TO ROLE MCP_ACCESS_ROLE;

-- ###########################################################################
-- # STEP 3: Check Your User Has MCP_ACCESS_ROLE
-- ###########################################################################

-- Check current user's role grants
-- EXPECTED: Should show MCP_ACCESS_ROLE among your assigned roles
SHOW GRANTS TO USER CURRENT_USER();

-- ###########################################################################
-- # STEP 4: Check Cortex Search Service Access
-- ###########################################################################

-- Check if we can see the Cortex Search Service
USE ROLE SYSADMIN;

-- EXPECTED: Should show CKE_SNOWFLAKE_DOCS_SERVICE
SHOW CORTEX SEARCH SERVICES IN SCHEMA SNOWFLAKE_DOCUMENTATION.SHARED;

-- Check grants on Cortex Search Service
-- EXPECTED: Should show USAGE granted to PUBLIC or other roles
SHOW GRANTS ON CORTEX SEARCH SERVICE SNOWFLAKE_DOCUMENTATION.SHARED.CKE_SNOWFLAKE_DOCS_SERVICE;

-- ###########################################################################
-- # STEP 5: Check Database Import Privileges
-- ###########################################################################

-- Check SNOWFLAKE_DOCUMENTATION database grants
-- EXPECTED: Should show IMPORTED PRIVILEGES granted to MCP_ACCESS_ROLE
SHOW GRANTS ON DATABASE SNOWFLAKE_DOCUMENTATION;

-- ###########################################################################
-- # STEP 6: Test MCP_ACCESS_ROLE Can Access MCP Server
-- ###########################################################################

-- Switch to MCP_ACCESS_ROLE to test permissions
USE ROLE MCP_ACCESS_ROLE;

-- Can MCP_ACCESS_ROLE see the MCP server?
-- EXPECTED: Should show SNOWFLAKE_MCP_SERVER
SHOW MCP SERVERS IN SCHEMA SNOWFLAKE_INTELLIGENCE.MCP;

-- Can MCP_ACCESS_ROLE describe the MCP server?
-- EXPECTED: Should show server configuration details
DESC MCP SERVER SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER;

-- ###########################################################################
-- # STEP 7: Check Your PAT Token Details
-- ###########################################################################

-- Switch back to your normal role
USE ROLE SYSADMIN;

-- Check your PAT tokens
-- EXPECTED: Should show at least one token (likely named MCP_PAT_*)
-- NOTE: This will NOT show TOKEN_SECRET (that's only shown at creation time)
SHOW USER PROGRAMMATIC ACCESS TOKENS;

-- ###########################################################################
-- # STEP 8: Display MCP Server URL
-- ###########################################################################

-- Display your MCP server URL for reference
-- EXPECTED: Should return a valid HTTPS URL
-- COPY this URL for your MCP client configuration
SELECT 'https://' || LOWER(CURRENT_ORGANIZATION_NAME()) || '-' || LOWER(CURRENT_ACCOUNT_NAME()) || 
       '.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/mcp/mcp-servers/snowflake_mcp_server' 
AS mcp_url;

-- If the above returns NULL in the mcp_url column, try this legacy format:
-- SELECT 'https://' || LOWER(CURRENT_ACCOUNT()) || '.' || LOWER(CURRENT_REGION()) || 
--        '.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/mcp/mcp-servers/snowflake_mcp_server' 
-- AS mcp_url;

-- ###########################################################################
-- # TROUBLESHOOTING GUIDE
-- ###########################################################################

/*
COMMON ISSUES AND SOLUTIONS:
============================

1. STEP 1 ERROR: "MCP server does not exist"
   SOLUTION: Run setup_mcp.sql prerequisite commands to create MCP server

2. STEP 2 ERROR: "Role MCP_ACCESS_ROLE does not exist"
   SOLUTION: Run setup_mcp.sql to create the role and grants

3. STEP 3: MCP_ACCESS_ROLE not listed for your user
   SOLUTION: Run setup_mcp.sql Part 3 to assign role to your user

4. STEP 5: No IMPORTED PRIVILEGES grant to MCP_ACCESS_ROLE
   SOLUTION: Run setup_mcp.sql Part 2 to grant IMPORTED PRIVILEGES

5. STEP 6 ERROR: Permission denied accessing MCP server
   SOLUTION: Run setup_mcp.sql Parts 1-2 to grant proper permissions

6. STEP 7: No PAT tokens shown
   SOLUTION: Run create_token.sql to create a token

7. STEP 8: mcp_url column shows NULL
   SOLUTION: Uncomment and run the legacy format query

8. MCP CLIENT ERROR: "Access denied" when using PAT token
   POSSIBLE CAUSES:
   a) Token was created BEFORE MCP_ACCESS_ROLE was assigned to your user
      SOLUTION: Create a new token with create_token.sql
   
   b) Token is expired (default 365 days)
      SOLUTION: Create a new token with create_token.sql
   
   c) Wrong role being used by token
      SOLUTION: Tokens inherit ALL roles granted to user, including MCP_ACCESS_ROLE
      
   d) Wrong MCP server URL
      SOLUTION: Copy URL from Step 8 output

9. MCP CLIENT ERROR: "Resource not found"
   SOLUTION: Verify MCP server URL is correct (case-sensitive, lowercase recommended)

10. ALL STEPS WORK but MCP client still fails
    SOLUTION: Issue is likely in MCP client configuration:
    - Check token format (should start with eyJ...)
    - Check URL format (must be exact match from Step 8)
    - Check network connectivity to Snowflake
    - Check for typos in database/schema/server names
*/

