#!/bin/bash

# Gemini CLI Bridge Status Check Script

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Gemini CLI Bridge Status ===${NC}\n"

PORT="${GEMINI_MCP_PORT:-8765}"
HOST="127.0.0.1"
BASE_URL="http://$HOST:$PORT"
PID_FILE="$HOME/.gemini-bridge.pid"
LOG_FILE="$HOME/gemini-bridge.log"

# Check PID file
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Process running (PID: $PID)${NC}"
    else
        echo -e "${RED}✗ PID file exists but process not running${NC}"
    fi
else
    echo -e "${YELLOW}⚠ No PID file found${NC}"
fi

# Check if port is in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    PORT_PID=$(lsof -t -i:$PORT)
    echo -e "${GREEN}✓ Port $PORT is in use (PID: $PORT_PID)${NC}"
else
    echo -e "${RED}✗ Port $PORT is not in use${NC}"
fi

# Check API endpoint
echo -e "\n${BLUE}Testing API endpoint...${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/v1/models" 2>/dev/null)

if [ "$response" = "200" ]; then
    echo -e "${GREEN}✓ API is responding (HTTP $response)${NC}"
    echo -e "\n${BLUE}Available models:${NC}"
    curl -s "$BASE_URL/v1/models" | python3 -m json.tool 2>/dev/null || echo "Unable to parse models response"
elif [ "$response" = "000" ]; then
    echo -e "${RED}✗ Cannot connect to API${NC}"
else
    echo -e "${YELLOW}⚠ API returned HTTP $response${NC}"
fi

# Check environment variable
echo -e "\n${BLUE}Environment check:${NC}"
if [ -z "$GOOGLE_API_KEY" ]; then
    echo -e "${RED}✗ GOOGLE_API_KEY not set${NC}"
else
    KEY_LEN=${#GOOGLE_API_KEY}
    MASKED_KEY="${GOOGLE_API_KEY:0:8}...${GOOGLE_API_KEY: -4}"
    echo -e "${GREEN}✓ GOOGLE_API_KEY is set ($KEY_LEN chars): $MASKED_KEY${NC}"
fi

# Show recent logs
if [ -f "$LOG_FILE" ]; then
    echo -e "\n${BLUE}Recent log entries (last 10 lines):${NC}"
    tail -10 "$LOG_FILE"
else
    echo -e "\n${YELLOW}⚠ Log file not found: $LOG_FILE${NC}"
fi

echo -e "\n${BLUE}Commands:${NC}"
echo -e "Start:  ${YELLOW}$HOME/start-gemini-bridge.sh${NC}"
echo -e "Stop:   ${YELLOW}$HOME/stop-gemini-bridge.sh${NC}"
echo -e "Logs:   ${YELLOW}tail -f $LOG_FILE${NC}"
echo ""
