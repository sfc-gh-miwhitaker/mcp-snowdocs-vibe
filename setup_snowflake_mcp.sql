/*
 * Copyright 2025 Snowflake Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Name: setup_snowflake_mcp.sql
 * Synopsis: Provision the Snowflake Documentation Cortex Knowledge Extension,
 *           expose it via a managed MCP server, and issue a teaching-ready PAT
 *           for API clients.
 * Author: M. Whitaker
 * Created: 2025-10-08
 * Modified: 2025-10-08 - Initial version for Snowflake MCP enablement workshop.
 */

-- ###########################################################################
-- # IMPORTANT: This script follows Snowflake best practices by avoiding     #
-- # ACCOUNTADMIN for routine operations. It uses SYSADMIN for database      #
-- # creation and SECURITYADMIN for role management, as recommended in:      #
-- # https://docs.snowflake.com/user-guide/security-access-control-considerations #
-- #                                                                          #
-- # Prerequisites:                                                           #
-- # - User must have SYSADMIN and SECURITYADMIN roles granted                #
-- # - Marketplace listing must already be accepted (one-time ACCOUNTADMIN task)#
-- ###########################################################################

-- Accept marketplace terms ONCE as ACCOUNTADMIN (idempotent; safe to rerun)
USE ROLE ACCOUNTADMIN;
CALL SYSTEM$ACCEPT_LEGAL_TERMS('DATA_EXCHANGE_LISTING', 'GZSTZ67BY9OQ4');

-- Switch to SECURITYADMIN for role operations per Snowflake best practices
USE ROLE SECURITYADMIN;

-- Object names are standardized to align with Snowflake field team runbooks.
SET session_user_name = CURRENT_USER();

-- ###########################################################################
-- # Section 1: Create MCP roles using SECURITYADMIN (best practice pattern). #
-- ###########################################################################

-- Create application role for managing MCP infrastructure
CREATE ROLE IF NOT EXISTS SNOWFLAKE_MCP_APP_ROLE;

-- Create least-privilege consumer role for end users
CREATE ROLE IF NOT EXISTS SNOWFLAKE_MCP_USER_ROLE;

-- Grant roles following Snowflake's recommended role hierarchy:
-- SECURITYADMIN manages roles, SYSADMIN manages databases
GRANT ROLE SNOWFLAKE_MCP_APP_ROLE TO ROLE SYSADMIN;
GRANT ROLE SNOWFLAKE_MCP_USER_ROLE TO ROLE SYSADMIN;

-- Grant roles to the executing user for immediate testing
GRANT ROLE SNOWFLAKE_MCP_APP_ROLE TO USER IDENTIFIER($SESSION_USER_NAME);
GRANT ROLE SNOWFLAKE_MCP_USER_ROLE TO USER IDENTIFIER($SESSION_USER_NAME);

-- ###########################################################################
-- # Section 2: Mount the Snowflake Documentation CKE using SYSADMIN.        #
-- ###########################################################################

-- Switch to SYSADMIN for database operations
USE ROLE SYSADMIN;

-- Create database from marketplace listing. Uses CREATE OR REPLACE to ensure
-- the latest version is mounted. For existing deployments, consider:
--   CREATE DATABASE IF NOT EXISTS ... followed by ALTER DATABASE ... REFRESH LISTING
CREATE OR REPLACE DATABASE SNOWFLAKE_DOCUMENTATION
  FROM LISTING 'GZSTZ67BY9OQ4';

-- Grant read access on the shared CKE database to both MCP roles.
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_DOCUMENTATION
  TO ROLE SNOWFLAKE_MCP_APP_ROLE;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_DOCUMENTATION
  TO ROLE SNOWFLAKE_MCP_USER_ROLE;

-- ###########################################################################
-- # Section 3: Prepare SNOWFLAKE_INTELLIGENCE database/schema for MCP server.#
-- ###########################################################################

-- Create the shared intelligence database if it doesn't exist. This database
-- hosts multiple Snowflake AI/ML assets, so we use IF NOT EXISTS to avoid
-- disrupting existing objects. SYSADMIN is the natural owner per Snowflake RBAC.
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;

GRANT USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE SNOWFLAKE_MCP_APP_ROLE;
GRANT USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE SNOWFLAKE_MCP_USER_ROLE;

USE DATABASE SNOWFLAKE_INTELLIGENCE;

-- Create the MCP schema to house MCP servers and related views
CREATE SCHEMA IF NOT EXISTS MCP;

GRANT USAGE ON SCHEMA MCP TO ROLE SNOWFLAKE_MCP_APP_ROLE;
GRANT USAGE ON SCHEMA MCP TO ROLE SNOWFLAKE_MCP_USER_ROLE;

USE SCHEMA MCP;

-- ###########################################################################
-- # Section 4: Create the managed MCP server (still as SYSADMIN).           #
-- ###########################################################################

CREATE OR REPLACE MCP SERVER SNOWFLAKE_MCP_SERVER
FROM SPECIFICATION $$
tools:
  - name: "snowflake-docs-search"
    type: "CORTEX_SEARCH_SERVICE_QUERY"
    identifier: "SNOWFLAKE_DOCUMENTATION.SHARED.CKE_SNOWFLAKE_DOCS_SERVICE"
    description: "Surface Snowflake docs via Cortex Search for MCP clients."
    title: "Snowflake Documentation Cortex Search"
$$;

GRANT USAGE ON MCP SERVER SNOWFLAKE_MCP_SERVER
  TO ROLE SNOWFLAKE_MCP_APP_ROLE;
GRANT USAGE ON MCP SERVER SNOWFLAKE_MCP_SERVER
  TO ROLE SNOWFLAKE_MCP_USER_ROLE;

-- Confirm to the learner that the MCP server exposes the expected tool.
SHOW MCP SERVERS IN SCHEMA SNOWFLAKE_INTELLIGENCE.MCP;

-- ###########################################################################
-- # Section 5: Issue a programmatic access token (PAT) for the current user. #
-- ###########################################################################

-- The ALTER USER statement returns token_name and token_secret; capture and
-- vault token_secret immediately because Snowflake will not display it again.
ALTER USER ADD PROGRAMMATIC ACCESS TOKEN MCP_DEMO_PAT
  DAYS_TO_EXPIRY = 365
  COMMENT = 'Snowflake MCP demo token. Store securely and rotate per policy.';

-- ###########################################################################
-- # Section 6: Persist helper views for well-formatted MCP client configs.   #
-- ###########################################################################

-- Helper view that surfaces MCP server connection parameters for supported
-- AI coding assistants. The view dynamically constructs account-specific URLs
-- and provides links to each client's MCP configuration documentation.
-- 
-- NOTE: Verify documentation URLs are current before distributing to users.
CREATE OR REPLACE VIEW SNOWFLAKE_MCP_CLIENT_CONFIGS AS
WITH context AS (
  SELECT
    LOWER(CURRENT_ACCOUNT()) AS account_locator,
    LOWER(REPLACE(CURRENT_REGION(), '_', '-')) AS account_region,
    'https://docs.cursor.com' AS cursor_docs,
    'https://modelcontextprotocol.io/clients#claude-desktop' AS claude_docs,
    'https://github.com/features/copilot' AS copilot_docs
)
SELECT
  'Cursor' AS client,
  cursor_docs AS documentation_url,
  '~/.cursor/mcp.json' AS config_location,
  CONCAT(
    'https://', account_locator, '.', account_region,
    '.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/mcp/mcp-servers/snowflake_mcp_server'
  ) AS url,
  'Authorization' AS header_name,
  '<PASTE_MCP_DEMO_PAT_TOKEN_SECRET_HERE>' AS header_value,
  NULL::VARCHAR AS additional_notes
FROM context
UNION ALL
SELECT
  'Claude Code' AS client,
  claude_docs AS documentation_url,
  '~/Library/Application Support/Claude/claude_desktop_config.json' AS config_location,
  CONCAT(
    'https://', account_locator, '.', account_region,
    '.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/mcp/mcp-servers/snowflake_mcp_server'
  ) AS url,
  'Authorization' AS header_name,
  '<PASTE_MCP_DEMO_PAT_TOKEN_SECRET_HERE>' AS header_value,
  'Set "type": "http" inside the Claude config payload.' AS additional_notes
FROM context
UNION ALL
SELECT
  'GitHub Copilot' AS client,
  copilot_docs AS documentation_url,
  '~/.config/github-copilot/mcp.json' AS config_location,
  CONCAT(
    'https://', account_locator, '.', account_region,
    '.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/mcp/mcp-servers/snowflake_mcp_server'
  ) AS url,
  'authorization' AS header_name,
  '<PASTE_MCP_DEMO_PAT_TOKEN_SECRET_HERE>' AS header_value,
  'Restart the Copilot agent after updating the MCP configuration.' AS additional_notes
FROM context;

GRANT SELECT ON VIEW SNOWFLAKE_MCP_CLIENT_CONFIGS TO ROLE SNOWFLAKE_MCP_APP_ROLE;
GRANT SELECT ON VIEW SNOWFLAKE_MCP_CLIENT_CONFIGS TO ROLE SNOWFLAKE_MCP_USER_ROLE;

SELECT client,
       documentation_url,
       config_location,
       url,
       header_name,
       header_value,
       additional_notes
  FROM SNOWFLAKE_MCP_CLIENT_CONFIGS
 ORDER BY client;

-- End of script.

