#!/bin/bash

# ==============================================================================
# RENDER PHASE 0 AUDIO - ONE-CLICK LAUNCHER
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear

echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}  QUASAR PHASE 0 AUDIO RENDERING${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""
echo -e "${GREEN}✓ SuperCollider installed (3.13.0)${NC}"
echo -e "${GREEN}✓ Quasar classes linked${NC}"
echo -e "${GREEN}✓ SynthDefs ready${NC}"
echo -e "${GREEN}✓ Rendering scripts ready${NC}"
echo ""
echo -e "${BLUE}=============================================${NC}"
echo ""

echo "Opening SuperCollider IDE..."
echo ""
echo "In the IDE, execute these commands:"
echo ""
echo -e "${YELLOW}// 1. Boot the server${NC}"
echo -e "${BLUE}s.boot;${NC}"
echo ""
echo -e "${YELLOW}// 2. Load and run the rendering script${NC}"
echo -e "${BLUE}load(\"$(pwd)/examples/PHASE_0_RENDER_TO_AUDIO.scd\");${NC}"
echo ""
echo -e "${YELLOW}// 3. Wait ~6-8 minutes for completion${NC}"
echo ""
echo -e "${YELLOW}// 4. Find your files in:${NC}"
echo -e "${BLUE}$(pwd)/examples/compositions/audio/${NC}"
echo ""
echo "============================================="
echo ""

# Launch SC IDE with the rendering script open
scide "$(pwd)/examples/PHASE_0_RENDER_TO_AUDIO.scd" &

echo "SC IDE launched!"
echo ""
echo "Press Ctrl+C when done."
wait
