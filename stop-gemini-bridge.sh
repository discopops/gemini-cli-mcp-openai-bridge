#!/bin/bash

# Gemini CLI Bridge Stop Script

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Stopping Gemini CLI Bridge ===${NC}\n"

PID_FILE="$HOME/.gemini-bridge.pid"

# Check if PID file exists
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")

    # Check if process is running
    if ps -p $PID > /dev/null 2>&1; then
        echo -e "${YELLOW}Killing process $PID...${NC}"
        kill $PID
        sleep 1

        # Force kill if still running
        if ps -p $PID > /dev/null 2>&1; then
            echo -e "${YELLOW}Process still running, force killing...${NC}"
            kill -9 $PID
        fi

        echo -e "${GREEN}✓ Gemini CLI Bridge stopped${NC}"
        rm "$PID_FILE"
    else
        echo -e "${YELLOW}Process $PID not running${NC}"
        rm "$PID_FILE"
    fi
else
    echo -e "${YELLOW}No PID file found${NC}"

    # Try to find and kill by port
    PORT="${GEMINI_MCP_PORT:-8765}"
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}Found process on port $PORT, killing...${NC}"
        kill -9 $(lsof -t -i:$PORT)
        echo -e "${GREEN}✓ Process on port $PORT stopped${NC}"
    else
        echo -e "${YELLOW}No process found on port $PORT${NC}"
    fi
fi

echo ""
