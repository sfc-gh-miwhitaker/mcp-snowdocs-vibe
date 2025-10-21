/*
 * Name: diagnose_pat_auth.sql
 * Synopsis: Comprehensive diagnostics for PAT token authorization issues
 * Author: M. Whitaker
 * Created: 2025-10-21
 */

-- ###########################################################################
-- # STEP 1: Check MCP Server Existence and Grants
-- ###########################################################################

USE ROLE SYSADMIN;

-- Check MCP server existence
SHOW MCP SERVERS IN SCHEMA SNOWFLAKE_INTELLIGENCE.MCP;

-- Check grants on MCP server
SHOW GRANTS ON MCP SERVER SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER;

-- ###########################################################################
-- # STEP 2: Check PUBLIC Role Grants
-- ###########################################################################

-- Check PUBLIC role grants
SHOW GRANTS TO ROLE PUBLIC;

-- ###########################################################################
-- # STEP 3: Check Cortex Search Service Access
-- ###########################################################################

-- Check if we can see the Cortex Search Service
USE ROLE SYSADMIN;
SHOW CORTEX SEARCH SERVICES IN SCHEMA SNOWFLAKE_DOCUMENTATION.SHARED;

-- Check grants on Cortex Search Service
SHOW GRANTS ON CORTEX SEARCH SERVICE SNOWFLAKE_DOCUMENTATION.SHARED.CKE_SNOWFLAKE_DOCS_SERVICE;

-- ###########################################################################
-- # STEP 4: Check Database Import Privileges
-- ###########################################################################

-- Check SNOWFLAKE_DOCUMENTATION database grants
SHOW GRANTS ON DATABASE SNOWFLAKE_DOCUMENTATION;

-- ###########################################################################
-- # STEP 5: Test PUBLIC Role Access
-- ###########################################################################

-- Try to access as PUBLIC role
USE ROLE PUBLIC;

-- Can PUBLIC see the MCP server?
SHOW MCP SERVERS IN SCHEMA SNOWFLAKE_INTELLIGENCE.MCP;

-- Can PUBLIC describe the MCP server?
DESC MCP SERVER SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER;

-- ###########################################################################
-- # STEP 6: Check Your PAT Token Details
-- ###########################################################################

-- Check your PAT tokens
SHOW PROGRAMMATIC ACCESS TOKENS FOR USER CURRENT_USER();

