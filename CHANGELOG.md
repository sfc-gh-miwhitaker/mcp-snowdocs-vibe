# Changelog

All notable changes to the Snowflake MCP Server Setup project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1] - 2025-10-21

### 🎯 Major Improvements

**Security-First Architecture Overhaul**

This release represents a complete redesign focused on production-ready security and minimal privilege access.

### Added

#### Core Security Features
- **Minimal Privilege Access Pattern**: New `MCP_ACCESS_ROLE` with exactly 4 required grants (no more, no less)
- **Separate PAT Token Creation**: Isolated token generation in `create_pat_token.sql` for better security hygiene
- **Secure Setup Script**: New `secure_pat_setup.sql` with role-based access control and least-privilege design
- **Teardown Script**: `secure_pat_teardown.sql` for complete cleanup of all MCP resources
- **Blast Radius Documentation**: Clear security boundary analysis showing exactly what compromised tokens can/cannot access

#### Diagnostic & Testing Tools
- **Shell Verification Script**: `verify_mcp_server.sh` for automated connection testing with SSL validation
- **SQL Diagnostic Script**: `diagnose_pat_auth.sql` for troubleshooting authorization issues
- **Visual Documentation**: New `help/` directory with detailed guides
  - `help/START_HERE.md`: Quick start visual guide
  - `help/SECURITY_COMPARISON.md`: Detailed security analysis comparing approaches

#### Project Infrastructure
- **`.gitignore`**: Proper exclusions for Cursor internal files and sensitive data
- **Modular Documentation**: Separated concerns (root README for quickstart, help/ for deep dives)
- **Enterprise-Grade Structure**: Following project layout best practices per ruleset

### Changed

#### Breaking Changes
- **Replaced** `setup_snowflake_mcp.sql` with two-phase approach:
  1. `create_pat_token.sql` (user-level token creation)
  2. `secure_pat_setup.sql` (role-based access provisioning)
- **Account URL Format**: Enforces correct format (`orgname-accountname.snowflakecomputing.com`) for SSL compatibility

#### Enhancements
- **README.md**: Completely rewritten with:
  - 4-step quickstart (down from vague multi-step process)
  - Clear security guarantees section
  - Comprehensive troubleshooting guide
  - Project structure documentation
- **Documentation Organization**: Moved deep-dive docs to `help/` per project rules (only README.md in root)

### Removed

- **`setup_snowflake_mcp.sql`**: Replaced by secure two-phase approach
- **Overly Broad Permissions**: No longer using PUBLIC role or ACCOUNTADMIN for MCP access
- **Implicit Security Assumptions**: All security boundaries now explicitly documented

### Security

#### Vulnerability Fixes
- **Fixed**: Previous approach granted excessive privileges to PAT tokens
- **Fixed**: No documentation of blast radius if token compromised
- **Fixed**: Mixed responsibilities (token creation + access provisioning in single script)

#### Security Enhancements
- **Principle of Least Privilege**: MCP_ACCESS_ROLE has exactly 4 grants:
  1. `USAGE` on `SNOWFLAKE_INTELLIGENCE` database
  2. `USAGE` on `SNOWFLAKE_INTELLIGENCE.MCP` schema
  3. `USAGE` on MCP server object
  4. `IMPORTED PRIVILEGES` on `SNOWFLAKE_DOCUMENTATION` (read-only marketplace data)
- **Zero Data Access**: Compromised tokens CANNOT access user databases, schemas, or tables
- **No Write Permissions**: Tokens CANNOT create, modify, or delete any objects
- **No Query Execution**: Tokens CANNOT execute arbitrary SQL beyond MCP server calls
- **Audit Trail**: All role grants and token creation explicitly logged

### Documentation

#### New Documentation
- **Security Comparison**: `help/SECURITY_COMPARISON.md` shows before/after security posture
- **Visual Quick Start**: `help/START_HERE.md` with step-by-step visual guide
- **Troubleshooting Guide**: Comprehensive section in README with common issues and solutions
- **Clean Architecture**: Project structure follows enterprise-grade patterns per coding ruleset

#### Improved Documentation
- **README.md**: 
  - Reduced quickstart from 10+ steps to 4 clear phases
  - Added security guarantees section with explicit attacker capabilities
  - Included troubleshooting for 6 common issues
  - Added cleanup instructions
- **Inline Comments**: All SQL scripts now include purpose, dependencies, and security implications

### Technical Details

#### Script Changes
- **`create_pat_token.sql`**: 
  - Creates 365-day PAT token scoped to current user
  - Returns token secret with clear warning about one-time visibility
  - No role grants (separation of concerns)

- **`secure_pat_setup.sql`**:
  - Creates `MCP_ACCESS_ROLE` if not exists (idempotent)
  - Grants minimal privileges to role
  - Grants role to PAT token
  - Returns account-specific MCP server URL
  - Validates all prerequisites

- **`verify_mcp_server.sh`**:
  - SSL certificate validation
  - MCP endpoint health check
  - Returns server capabilities and protocol version
  - Provides configuration validation

- **`diagnose_pat_auth.sql`**:
  - Lists all PAT tokens for current user
  - Shows role grants for MCP_ACCESS_ROLE
  - Validates MCP server existence
  - Provides step-by-step diagnostic output

### Migration Guide

**From v1.0 to v1.1:**

If you set up MCP server using the old `setup_snowflake_mcp.sql`, follow these steps:

1. **Create new PAT token**:
   ```sql
   -- Run create_pat_token.sql
   -- Save the TOKEN_SECRET immediately
   ```

2. **Run secure setup**:
   ```sql
   -- Run secure_pat_setup.sql
   -- Copy the mcp_url from results
   ```

3. **Update MCP config**:
   ```json
   // Update ~/.cursor/mcp.json with new token
   {
     "mcpServers": {
       "Snowflake": {
         "url": "YOUR_NEW_MCP_URL",
         "headers": {
           "Authorization": "Bearer YOUR_NEW_TOKEN"
         }
       }
     }
   }
   ```

4. **Clean up old setup** (optional):
   ```sql
   -- If you had overly broad grants, review and revoke them
   -- The new MCP_ACCESS_ROLE is completely isolated
   ```

5. **Verify**:
   ```bash
   ./verify_mcp_server.sh
   ```

6. **Restart Cursor**

### Known Issues

- **Cursor Red Indicator**: MCP server may show red status in Cursor UI even when fully functional (see README troubleshooting)
- **First Connection Timeout**: Initial MCP handshake may take 10-30 seconds after Cursor restart

### Contributors

Thanks to all contributors who helped improve security and documentation in this release.

---

## [1.0] - 2025-10-20

### Added
- Initial release with basic MCP server setup
- Single-script setup approach (`setup_snowflake_mcp.sql`)
- Basic README documentation

### Known Issues (Fixed in 1.1)
- Overly broad permission grants
- No security boundary documentation
- Mixed token creation and access provisioning
- No diagnostic or testing tools

---

## Release Notes

### Version Naming Convention
- **Major version** (X.0): Breaking changes, architecture overhauls
- **Minor version** (X.Y): New features, enhancements, non-breaking changes
- **Patch version** (X.Y.Z): Bug fixes, documentation updates

### Support
- Report issues: [GitHub Issues](https://github.com/YOUR_USERNAME/YOUR_REPO/issues)
- Security issues: See SECURITY.md (if applicable)

### License
Apache License 2.0 - See LICENSE file for details

