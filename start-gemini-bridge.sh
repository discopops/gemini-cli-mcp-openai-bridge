#!/bin/bash

# Gemini CLI Bridge Startup Script
# This script starts the Gemini CLI Bridge server for Obsidian Copilot

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Gemini CLI Bridge Startup Script ===${NC}\n"

# Check if GOOGLE_API_KEY is set
if [ -z "$GOOGLE_API_KEY" ]; then
    echo -e "${YELLOW}WARNING: GOOGLE_API_KEY environment variable is not set${NC}"
    echo -e "${YELLOW}Please set it with: export GOOGLE_API_KEY='your-key-here'${NC}"
    echo -e "${YELLOW}Or add it to your ~/.zshrc or ~/.bashrc${NC}\n"

    read -p "Do you want to enter your Google API key now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter your Google API key: " api_key
        export GOOGLE_API_KEY="$api_key"
        echo -e "${GREEN}API key set for this session${NC}\n"
    else
        echo -e "${RED}Cannot start without API key. Exiting.${NC}"
        exit 1
    fi
fi

# Configuration
PORT="${GEMINI_MCP_PORT:-8765}"
HOST="127.0.0.1"
VAULT_DIR="/Users/BLW_M2_HOME/Vault"
MODE="configured"
LOG_FILE="$HOME/gemini-bridge.log"

# Check if port is already in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}Port $PORT is already in use${NC}"
    read -p "Do you want to kill the existing process? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Killing process on port $PORT...${NC}"
        kill -9 $(lsof -t -i:$PORT)
        sleep 1
    else
        echo -e "${RED}Cannot start with port in use. Exiting.${NC}"
        exit 1
    fi
fi

# Check if gemini-cli-bridge is installed
if ! command -v gemini-cli-bridge &> /dev/null; then
    echo -e "${RED}ERROR: gemini-cli-bridge not found${NC}"
    echo -e "${YELLOW}Install it with: npm install -g @modelcontextprotocol/server-gemini${NC}"
    exit 1
fi

echo -e "${GREEN}Starting Gemini CLI Bridge...${NC}"
echo -e "Port: ${YELLOW}$PORT${NC}"
echo -e "Host: ${YELLOW}$HOST${NC}"
echo -e "Target Dir: ${YELLOW}$VAULT_DIR${NC}"
echo -e "Mode: ${YELLOW}$MODE${NC}"
echo -e "Log File: ${YELLOW}$LOG_FILE${NC}\n"

# Start the server
gemini-cli-bridge \
  --port "$PORT" \
  --host "$HOST" \
  --target-dir "$VAULT_DIR" \
  --mode "$MODE" \
  --debug \
  >> "$LOG_FILE" 2>&1 &

# Get the PID
BRIDGE_PID=$!
echo $BRIDGE_PID > "$HOME/.gemini-bridge.pid"

# Wait a moment and check if it's still running
sleep 2

if ps -p $BRIDGE_PID > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Gemini CLI Bridge started successfully!${NC}"
    echo -e "PID: ${YELLOW}$BRIDGE_PID${NC}"
    echo -e "\nServer running at: ${GREEN}http://$HOST:$PORT/v1${NC}"
    echo -e "\nTest with: ${YELLOW}curl http://$HOST:$PORT/v1/models${NC}"
    echo -e "\nView logs: ${YELLOW}tail -f $LOG_FILE${NC}"
    echo -e "\nStop server: ${YELLOW}kill $BRIDGE_PID${NC}"
    echo -e "Or use: ${YELLOW}$HOME/stop-gemini-bridge.sh${NC}\n"
else
    echo -e "${RED}✗ Failed to start Gemini CLI Bridge${NC}"
    echo -e "${YELLOW}Check logs: tail -20 $LOG_FILE${NC}"
    exit 1
fi
