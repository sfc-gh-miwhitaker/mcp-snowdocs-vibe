#!/bin/bash
# Name: test_connection.sh
# Synopsis: Final verification that the MCP server is ready and responding
# Author: M. Whitaker
# Created: 2025-10-21
# Updated: 2025-10-22 (renamed from verify_mcp_server.sh)

set -e

# IMPORTANT: Update these values with your Snowflake account details
# Use organization-based URL format, not account locator format
# Correct format: https://orgname-accountname.snowflakecomputing.com
# Incorrect format: https://account.region.snowflakecomputing.com (will cause SSL errors)
MCP_URL="https://YOUR_ORG-YOUR_ACCOUNT.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/mcp/mcp-servers/snowflake_mcp_server"
HOSTNAME="YOUR_ORG-YOUR_ACCOUNT.snowflakecomputing.com"

# Read token from mcp.json if available, otherwise require manual update
if [ -f "$HOME/.cursor/mcp.json" ]; then
    TOKEN=$(grep -A 3 '"Snowflake"' "$HOME/.cursor/mcp.json" | grep 'Bearer' | cut -d'"' -f4 | cut -d' ' -f2)
    if [ -z "$TOKEN" ]; then
        echo "❌ Could not extract token from ~/.cursor/mcp.json"
        echo "Please update MCP_URL and HOSTNAME variables in this script (lines 11-12)"
        exit 1
    fi
    echo "Using token from ~/.cursor/mcp.json"
else
    echo "❌ ~/.cursor/mcp.json not found"
    echo "Please update MCP_URL and HOSTNAME variables in this script (lines 11-12)"
    echo "Or create ~/.cursor/mcp.json with your Snowflake MCP configuration"
    exit 1
fi

echo "=========================================="
echo "Snowflake MCP Server Verification"
echo "=========================================="
echo ""
echo "MCP Server URL: $MCP_URL"
echo ""

# Test 1: SSL Certificate
echo "Test 1: SSL Certificate Verification"
echo "---"
echo "Testing hostname: $HOSTNAME"
CERT_SUBJECT=$(echo | openssl s_client -servername "$HOSTNAME" \
    -connect "$HOSTNAME:443" 2>/dev/null | \
    openssl x509 -noout -subject 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "✅ SSL Certificate: Valid"
    echo "   $CERT_SUBJECT"
else
    echo "❌ SSL Certificate: Failed"
    echo "   Make sure you're using organization-based URL format"
fi
echo ""

# Test 2: MCP Server Endpoint Response
echo "Test 2: MCP Server Endpoint"
echo "---"

# MCP servers typically require a JSON-RPC request body
# Testing with a simple initialize request
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
    -X POST "$MCP_URL" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}')

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE:")

echo "HTTP Status: $HTTP_CODE"

case "$HTTP_CODE" in
    200)
        echo "✅ MCP Server: Ready and responding"
        echo ""
        echo "Response:"
        echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
        ;;
    401)
        echo "⚠️  MCP Server: Reachable but authorization failed"
        echo "   Check if token has expired or lacks proper grants"
        ;;
    400|390400)
        echo "✅ MCP Server: Reachable (requires valid JSON-RPC request)"
        echo ""
        echo "Response:"
        echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
        ;;
    404)
        echo "❌ MCP Server: Not found at this URL"
        ;;
    405)
        echo "✅ MCP Server: Exists (but needs proper JSON-RPC request format)"
        ;;
    *)
        echo "❓ Unexpected response: $HTTP_CODE"
        echo "$BODY" | head -10
        ;;
esac

echo ""
echo "=========================================="
echo "Configuration Status"
echo "=========================================="
echo ""
echo "Your ~/.cursor/mcp.json should contain:"
echo ""
echo '{'
echo '  "mcpServers": {'
echo '    "Snowflake": {'
echo "      \"url\": \"$MCP_URL\","
echo '      "headers": {'
echo "        \"Authorization\": \"Bearer YOUR_TOKEN_HERE\""
echo '      }'
echo '    }'
echo '  }'
echo '}'
echo ""
echo "⚠️  IMPORTANT: URL Format"
echo "   ✅ Correct:   https://orgname-accountname.snowflakecomputing.com/..."
echo "   ❌ Incorrect: https://account.region.snowflakecomputing.com/..."
echo ""
echo "   Using the wrong format will cause SSL certificate errors."
echo ""
echo "Next steps:"
echo "1. Verify your ~/.cursor/mcp.json uses the correct URL format above"
echo "2. Restart Cursor for the MCP config to take effect"
echo "3. The Snowflake MCP server should now be available"
echo "4. Check token expiration if authentication fails"
echo ""

