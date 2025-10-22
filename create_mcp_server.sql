/*
 * Name: create_mcp_server.sql
 * Synopsis: One-time setup to create the Snowflake MCP server
 * Author: M. Whitaker
 * Created: 2025-10-22
 * 
 * PURPOSE:
 * This script creates the MCP server that exposes Snowflake documentation.
 * You only need to run this ONCE per Snowflake account.
 * 
 * WHEN TO RUN:
 * - First time setting up MCP in your Snowflake account
 * - If you get "Agent Server does not exist" error in setup_mcp.sql
 * 
 * PREREQUISITES:
 * - ACCOUNTADMIN role (for accepting the documentation share)
 * - SYSADMIN role (for creating the MCP server)
 * 
 * HOW TO RUN:
 * 1. Click "Run All" in Snowsight
 * 2. Verify success (should see "MCP server created successfully")
 * 3. Then run setup_mcp.sql to configure access
 */

-- ###########################################################################
-- # STEP 1: Accept Snowflake Documentation Share
-- ###########################################################################

USE ROLE ACCOUNTADMIN;

-- Import the Snowflake documentation database from the share
-- This contains the Cortex Search Service with Snowflake docs
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_DOCUMENTATION 
  FROM SHARE SNO_ACCOUNT.SNO_COMMON.DOCS_SHARE;

-- Verify the database was created
SHOW DATABASES LIKE 'SNOWFLAKE_DOCUMENTATION';

-- ###########################################################################
-- # STEP 2: Create MCP Server Infrastructure
-- ###########################################################################

USE ROLE SYSADMIN;

-- Create the SNOWFLAKE_INTELLIGENCE database if it doesn't exist
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE
  COMMENT = 'Snowflake Intelligence features including MCP servers';

-- Create the MCP schema
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.MCP
  COMMENT = 'Model Context Protocol (MCP) servers';

-- Verify the schema was created
SHOW SCHEMAS IN DATABASE SNOWFLAKE_INTELLIGENCE;

-- ###########################################################################
-- # STEP 3: Create the MCP Server
-- ###########################################################################

-- Create the MCP server that exposes Snowflake documentation
-- This uses the Cortex Search Service from SNOWFLAKE_DOCUMENTATION
CREATE OR REPLACE MCP SERVER SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER
  AS CORTEX SEARCH SERVICE SNOWFLAKE_DOCUMENTATION.SHARED.CKE_SNOWFLAKE_DOCS_SERVICE
  COMMENT = 'MCP server providing access to Snowflake documentation via Cortex Search';

-- Verify the MCP server was created
SHOW MCP SERVERS IN SCHEMA SNOWFLAKE_INTELLIGENCE.MCP;

-- ###########################################################################
-- # VERIFICATION
-- ###########################################################################

-- Check the MCP server details
DESC MCP SERVER SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER;

-- Display success message
SELECT '✅ MCP server created successfully!' AS status,
       'Next step: Run setup_mcp.sql to configure access' AS next_action;

/*
WHAT WAS CREATED:
=================
1. ✅ SNOWFLAKE_DOCUMENTATION database (from share)
2. ✅ SNOWFLAKE_INTELLIGENCE database (for MCP infrastructure)
3. ✅ SNOWFLAKE_INTELLIGENCE.MCP schema (for MCP servers)
4. ✅ SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER (the MCP server)

NEXT STEPS:
===========
1. ✅ Run setup_mcp.sql to create MCP_ACCESS_ROLE and configure permissions
2. ✅ Use your PAT token (from create_token.sql) with the MCP server
3. ✅ Configure your IDE (Cursor, Claude Desktop, VS Code, etc.)

TROUBLESHOOTING:
================
- If "share does not exist" error: Check your Snowflake Marketplace access
- If "insufficient privileges" error: Ensure you have ACCOUNTADMIN and SYSADMIN roles
- If MCP server already exists: Safe to re-run (uses CREATE OR REPLACE)
*/

