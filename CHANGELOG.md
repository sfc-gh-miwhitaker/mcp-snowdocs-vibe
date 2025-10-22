# Changelog

All notable changes to the Snowflake MCP Server Setup project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added - Multi-IDE Configuration Support

**Enhanced IDE compatibility documentation** to help users set up MCP server across different development environments.

#### Documentation Enhancements

- **Step 3 Configuration**: Expanded with collapsible sections for each IDE
  - ✅ **Cursor**: Complete setup with OS-specific paths and restart instructions
  - ✅ **Claude Desktop**: Full configuration for macOS, Windows, and Linux
  - ✅ **VS Code**: Setup via Continue.dev extension with complete instructions
  - ✅ **Other IDEs**: Generic configuration pattern for MCP-compatible tools

- **IDE Compatibility Matrix**: New comparison table showing:
  - MCP support status for 4 major IDEs (Cursor, Claude Desktop, VS Code, Zed)
  - Setup complexity ratings
  - Configuration file locations
  - Visual indicators for each IDE
  - Testing status

- **Enhanced Troubleshooting**: IDE-specific debugging steps for Cursor, Claude Desktop, and VS Code

#### Configuration Features

**For Each IDE:**
- OS-specific file paths (macOS, Windows, Linux)
- Post-configuration verification steps
- Visual indicators to confirm MCP is working
- Restart instructions

**Supported IDEs:**
- Cursor (fully tested ✅)
- Claude Desktop (fully tested ✅)
- VS Code via Continue.dev extension (community tested ⚠️)
- Zed (community tested ⚠️)

---

## [1.3] - 2025-10-22

### Changed - File Naming Simplification

**Major user experience improvement**: All files renamed to remove jargon and improve discoverability for new Snowflake users.

#### File Renames

| Old Name | New Name | Rationale |
|----------|----------|-----------|
| `create_pat_token.sql` | **`create_token.sql`** | Shorter; "PAT" is Snowflake jargon learned inside script |
| `secure_pat_setup.sql` | **`setup_mcp.sql`** | Focuses on action (setup MCP); "secure" is implied |
| `secure_pat_teardown.sql` | **`cleanup_mcp.sql`** | "cleanup" more intuitive than "teardown" |
| `diagnose_pat_auth.sql` | **`troubleshoot.sql`** | User-friendly verb; shorter |
| `verify_mcp_server.sh` | **`test_connection.sh`** | "test" more common than "verify" |
| `help/START_HERE.md` | **`help/GETTING_STARTED.md`** | Industry-standard naming |
| `help/SECURITY_COMPARISON.md` | **`help/SECURITY.md`** | Simpler, more direct |

#### Documentation Enhancements

- **README.md**: Added prominent "First time here?" callout at top directing users to the 3-file workflow
- **README.md**: Updated all internal references to use new filenames
- **README.md**: Enhanced project structure section with clearer descriptions
- **help/GETTING_STARTED.md**: Updated to 3-step workflow (was 4 steps)
- **help/GETTING_STARTED.md**: All references updated to new filenames
- **help/SECURITY.md**: All references updated to new filenames
- **All SQL scripts**: Updated headers with new names and "renamed from" notes
- **All SQL scripts**: Updated cross-references to other scripts

### Added

- Enhanced beginner experience with prominent workflow callout in README
- File rename history documented in each file header

### Breaking Changes

**This is a breaking change if you have external documentation referencing old filenames.**

| Impact | Migration |
|--------|-----------|
| **Git history** | File renames tracked with `git mv` - history preserved |
| **External docs** | Update any references to use new filenames |
| **Bookmarks/Links** | GitHub will redirect, but update bookmarks |
| **Scripts/automation** | Update any scripts referencing old filenames |

### Migration Guide

**For existing users:**

1. **Pull latest changes**: `git pull origin main`
2. **Files automatically renamed**: Git handles this transparently
3. **Update your documentation**: If you've documented these scripts elsewhere, update references
4. **No functional changes**: Scripts work identically, only names changed

### Rationale

**User Research Findings:**
- New Snowflake users found "PAT", "secure_", "diagnose" intimidating
- Inconsistent naming patterns (action-based vs. security-focused) caused confusion
- Two entry points (README vs. START_HERE.md) created friction
- File naming didn't follow standard GitHub conventions

**Design Principles Applied:**
1. **Reduce jargon**: Remove Snowflake-specific terms from filenames
2. **Action-focused**: Use clear verbs (create, setup, cleanup, test)
3. **Consistent**: All files follow same naming pattern
4. **Standard**: Follow GitHub and industry conventions
5. **Discoverable**: Names clearly indicate purpose without reading docs

**Benefits:**
- ✅ **Faster onboarding**: Users immediately understand file purpose
- ✅ **Less intimidating**: Simpler names reduce cognitive load
- ✅ **More intuitive**: Action-based naming matches mental model
- ✅ **Industry standard**: Follows conventions users expect
- ✅ **Better SEO**: Simpler names easier to search and reference

---

## [1.2] - 2025-10-22

### Changed

#### Teardown Script Enhancement
- **Updated `secure_pat_teardown.sql`**: Now preserves reusable infrastructure
  - **Removes**: MCP server and MCP_ACCESS_ROLE (resources created by setup)
  - **Preserves**: SNOWFLAKE_INTELLIGENCE database and schemas (reusable across examples)
  - **Preserves**: SNOWFLAKE_DOCUMENTATION database (imported share, may be used elsewhere)
  - **Preserves**: PAT tokens (user-managed, may be needed for other integrations)
  
#### Documentation Updates
- **Enhanced `diagnose_pat_auth.sql`**: 
  - Added comprehensive header with PURPOSE and expected behavior
  - Added inline EXPECTED results for each diagnostic step
  - Added Step 8 to display MCP server URL for reference
  - Added extensive troubleshooting guide with 10 common failure scenarios
  
- **Updated README.md**: 
  - Clarified cleanup section to explain preservation strategy
  - Added explicit list of what gets removed vs. preserved
  
- **Updated `help/START_HERE.md`**: 
  - Updated teardown description to reflect new preservation behavior
  
- **Updated `help/SECURITY_COMPARISON.md`**: 
  - Updated cleanup instructions to explain what gets preserved

### Rationale

**Why preserve infrastructure?**
- SNOWFLAKE_INTELLIGENCE database and its schemas (TOOLS, AGENTS, MCP) are commonly reused across multiple Snowflake examples and tutorials
- SNOWFLAKE_DOCUMENTATION is an imported marketplace share that may be referenced by other features
- PAT tokens may be used for other Snowflake integrations beyond MCP
- Users can easily recreate the MCP server while keeping the foundation in place

**Why remove MCP server?**
- MCP server is the specific resource created for this example
- Removal demonstrates proper cleanup of example-specific resources
- Easy to recreate with `secure_pat_setup.sql` if needed

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

