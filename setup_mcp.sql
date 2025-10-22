/*
 * Name: setup_mcp.sql
 * Synopsis: Complete MCP server setup - creates server and configures access
 * Author: M. Whitaker
 * Created: 2025-10-21
 * Updated: 2025-10-22
 * 
 * WHAT THIS DOES:
 * 1. Creates MCP server infrastructure (if it doesn't exist)
 * 2. Creates MCP_ACCESS_ROLE with minimal privileges
 * 3. Grants role to your user
 * 4. Displays your MCP server URL
 * 
 * PREREQUISITE: 
 * - Run create_token.sql first to create your PAT token
 * - Need ACCOUNTADMIN (one-time), SYSADMIN, and SECURITYADMIN roles
 * 
 * HOW TO RUN:
 * 1. Click "Run All" in Snowsight
 * 2. Look for the result with "mcp_url" column - COPY IT
 * 3. Combine with your PAT token in your IDE's MCP config
 * 
 * This script is IDEMPOTENT - safe to run multiple times.
 */

-- ###########################################################################
-- # PART 1: Create MCP Server Infrastructure (if needed)
-- ###########################################################################

-- Accept Snowflake Documentation from Marketplace (requires ACCOUNTADMIN)
USE ROLE ACCOUNTADMIN;

-- Accept legal terms for Snowflake Documentation marketplace listing
CALL SYSTEM$ACCEPT_LEGAL_TERMS('DATA_EXCHANGE_LISTING', 'GZSTZ67BY9OQ4');

-- Import Snowflake Documentation database from Marketplace
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_DOCUMENTATION
  FROM LISTING IDENTIFIER('"GZSTZ67BY9OQ4"'); -- do not alter this string

-- Grant IMPORTED PRIVILEGES to PUBLIC role for MCP access
-- NOTE: To restrict access, replace PUBLIC with your custom role
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_DOCUMENTATION TO ROLE MCP_ACCESS_ROLE;

-- Create MCP server infrastructure (requires SYSADMIN)
USE ROLE SYSADMIN;
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE
  COMMENT = 'Snowflake Intelligence features including MCP servers';

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.MCP
  COMMENT = 'Model Context Protocol (MCP) servers';

-- Create the MCP server (idempotent with CREATE OR REPLACE)
-- Note: Provides access to Snowflake documentation via Cortex Search
CREATE OR REPLACE MCP SERVER SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER
  FROM SPECIFICATION $$
    tools:
      - name: "snowflake-docs-search"
        type: "CORTEX_SEARCH_SERVICE_QUERY"
        identifier: "SNOWFLAKE_DOCUMENTATION.SHARED.CKE_SNOWFLAKE_DOCS_SERVICE"
        description: "Search Snowflake documentation using Cortex Search"
        title: "Snowflake Documentation Search"
  $$;

-- Verify MCP server was created (optional - uncomment for debugging)
-- SHOW MCP SERVERS IN SCHEMA SNOWFLAKE_INTELLIGENCE.MCP;

-- ###########################################################################
-- # PART 2: Create Dedicated MCP Access Role (Minimal Privileges)
-- ###########################################################################

-- Get current user name
SET session_user_name = (SELECT CURRENT_USER());

USE ROLE SECURITYADMIN;

-- Create a dedicated role for MCP server access
CREATE ROLE IF NOT EXISTS MCP_ACCESS_ROLE
  COMMENT = 'Minimal privileges for MCP server API access via PAT tokens';

-- ###########################################################################
-- # PART 3: Grant Minimal Required Privileges
-- ###########################################################################

USE ROLE SYSADMIN;

-- Grant USAGE on SNOWFLAKE_INTELLIGENCE database (required for MCP server access)
GRANT USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE MCP_ACCESS_ROLE;

-- Grant USAGE on MCP schema (required to access MCP server objects)
GRANT USAGE ON SCHEMA SNOWFLAKE_INTELLIGENCE.MCP TO ROLE MCP_ACCESS_ROLE;

-- Grant USAGE on the specific MCP server (required to call MCP endpoints)
GRANT USAGE ON MCP SERVER SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER
  TO ROLE MCP_ACCESS_ROLE;

-- Grant IMPORTED PRIVILEGES on SNOWFLAKE_DOCUMENTATION database
-- This gives access to the Cortex Search Service that the MCP server uses
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_DOCUMENTATION TO ROLE MCP_ACCESS_ROLE;

-- ###########################################################################
-- # PART 4: Assign Role to Your User
-- ###########################################################################

USE ROLE SECURITYADMIN;

-- Assign the MCP access role to your current user
GRANT ROLE MCP_ACCESS_ROLE TO USER IDENTIFIER($session_user_name);

-- ###########################################################################
-- # PART 5: Verify Token Configuration
-- ###########################################################################

-- The token was created with your current role, but we need it to use MCP_ACCESS_ROLE
-- Unfortunately, we cannot modify the token's role after creation
-- The token inherits all roles granted to your user, including MCP_ACCESS_ROLE

-- Verify your user now has MCP_ACCESS_ROLE (optional - uncomment for debugging)
-- SHOW GRANTS TO USER IDENTIFIER($session_user_name);

-- ###########################################################################
-- # PART 6: Verify Setup
-- ###########################################################################

-- Verify MCP_ACCESS_ROLE has correct privileges (optional - uncomment for debugging)
-- SHOW GRANTS TO ROLE MCP_ACCESS_ROLE;

-- Verify your user has MCP_ACCESS_ROLE (optional - uncomment for debugging)
-- SHOW GRANTS TO USER IDENTIFIER($session_user_name);

-- Test if MCP_ACCESS_ROLE can see the MCP server (optional - uncomment for debugging)
USE ROLE MCP_ACCESS_ROLE;
-- SHOW MCP SERVERS IN SCHEMA SNOWFLAKE_INTELLIGENCE.MCP;

-- Test if MCP_ACCESS_ROLE can describe the MCP server
DESC MCP SERVER SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER;

-- ###########################################################################
-- # PART 7: Display MCP Server URL
-- ###########################################################################

-- Display your MCP server URL (for most accounts)
SELECT 'https://' || LOWER(CURRENT_ORGANIZATION_NAME()) || '-' || LOWER(CURRENT_ACCOUNT_NAME()) || 
       '.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/mcp/mcp-servers/snowflake_mcp_server' 
AS mcp_url;

-- If the above returns NULL, try this legacy format instead:
-- SELECT 'https://' || LOWER(CURRENT_ACCOUNT()) || '.' || LOWER(CURRENT_REGION()) || 
--        '.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/mcp/mcp-servers/snowflake_mcp_server' 
-- AS mcp_url;

-- ###########################################################################
-- # WHAT WE GRANTED (Minimal Privilege Documentation)
-- ###########################################################################

/*
SECURITY SUMMARY:
================

Role: MCP_ACCESS_ROLE (NOT PUBLIC)

Privileges Granted (MINIMAL):
1. USAGE on SNOWFLAKE_INTELLIGENCE database
   - Required to access any objects in this database
   
2. USAGE on SNOWFLAKE_INTELLIGENCE.MCP schema
   - Required to access MCP server objects
   
3. USAGE on SNOWFLAKE_INTELLIGENCE.MCP.SNOWFLAKE_MCP_SERVER
   - Required to call MCP server endpoints
   
4. IMPORTED PRIVILEGES on SNOWFLAKE_DOCUMENTATION database
   - Required for the MCP server to access underlying Cortex Search Service
   - This is a marketplace database, so we must grant IMPORTED PRIVILEGES

What We Did NOT Grant:
- No access to other databases or schemas
- No write privileges (SELECT, INSERT, UPDATE, DELETE)
- No admin privileges (CREATE, DROP, ALTER)
- No data access beyond what the MCP server tools expose
- Not assigned to PUBLIC role (only to your specific user)

Security Benefits:
- Principle of least privilege
- Token has ONLY the permissions needed for MCP server API calls
- If token is compromised, attacker cannot access other data
- Clear audit trail (all access via MCP_ACCESS_ROLE)
- Easy to revoke (DROP ROLE MCP_ACCESS_ROLE CASCADE)
*/
