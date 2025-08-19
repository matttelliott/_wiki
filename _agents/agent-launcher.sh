#!/bin/bash

# Wiki Agent Launcher
# A menu system for selecting and running specialized Claude agents

AGENTS_DIR="$HOME/_wiki/_agents"
WIKI_DIR="$HOME/_wiki"

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Function to display the header
show_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════╗"
    echo "║       Wiki Agent Launcher 🤖          ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to extract agent description from file
get_agent_description() {
    local file=$1
    # Try to extract the first line after "## Agent Identity" or similar
    local desc=$(grep -A 1 "^## Agent Identity\|^## Purpose\|^# " "$file" 2>/dev/null | head -2 | tail -1 | sed 's/^[# ]*//')
    if [ -z "$desc" ]; then
        desc="No description available"
    fi
    echo "$desc" | cut -c1-60
}

# Function to list and select agents
select_agent() {
    show_header
    
    echo -e "${YELLOW}Available Agents:${NC}\n"
    
    # Find all .md files in agents directory (excluding README and this launcher)
    agents=()
    descriptions=()
    
    while IFS= read -r agent_file; do
        if [[ $(basename "$agent_file") != "README.md" && $(basename "$agent_file") != "agent-launcher.sh" ]]; then
            agents+=("$agent_file")
            desc=$(get_agent_description "$agent_file")
            descriptions+=("$desc")
        fi
    done < <(find "$AGENTS_DIR" -maxdepth 1 -name "*.md" -type f | sort)
    
    # Display agents with numbers
    for i in "${!agents[@]}"; do
        agent_name=$(basename "${agents[$i]}" .md | sed 's/-agent$//' | sed 's/-/ /g')
        # Capitalize first letter of each word
        agent_name=$(echo "$agent_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
        
        echo -e "${GREEN}[$((i+1))]${NC} ${BOLD}$agent_name${NC}"
        echo -e "    ${descriptions[$i]}\n"
    done
    
    echo -e "${BLUE}[C]${NC} Create new agent"
    echo -e "${BLUE}[L]${NC} List agent details"
    echo -e "${RED}[Q]${NC} Quit\n"
    
    echo -n "Select an option: "
    read -r choice
    
    case $choice in
        [Qq])
            echo "Goodbye! 👋"
            exit 0
            ;;
        [Cc])
            create_new_agent
            ;;
        [Ll])
            list_agent_details
            ;;
        [1-9]|[1-9][0-9])
            if [ "$choice" -le "${#agents[@]}" ] && [ "$choice" -ge 1 ]; then
                launch_agent "${agents[$((choice-1))]}"
            else
                echo -e "${RED}Invalid selection${NC}"
                sleep 2
                select_agent
            fi
            ;;
        *)
            echo -e "${RED}Invalid selection${NC}"
            sleep 2
            select_agent
            ;;
    esac
}

# Function to launch selected agent
launch_agent() {
    local agent_file=$1
    local agent_name=$(basename "$agent_file" .md | sed 's/-agent$//' | sed 's/-/ /g')
    
    show_header
    echo -e "${GREEN}Launching ${BOLD}$agent_name${NC}${GREEN} agent...${NC}\n"
    echo -e "${CYAN}Tip: This agent will have special behaviors and conversation style.${NC}"
    echo -e "${CYAN}Type your message and the agent will respond according to its training.${NC}\n"
    sleep 1
    
    # Launch Claude with the agent's system prompt
    cd "$WIKI_DIR"
    claude --append-system-prompt "$(cat "$agent_file")"
}

# Function to create a new agent (placeholder)
create_new_agent() {
    show_header
    echo -e "${YELLOW}Agent Creation Wizard${NC}\n"
    echo "This feature is coming soon!"
    echo "For now, create agent files manually in: $AGENTS_DIR"
    echo ""
    echo "Agent files should:"
    echo "1. Be named with format: agent-name-agent.md"
    echo "2. Include ## Agent Identity section"
    echo "3. Define the agent's behavior and specialization"
    echo ""
    echo -n "Press Enter to return to menu..."
    read -r
    select_agent
}

# Function to list agent details
list_agent_details() {
    show_header
    echo -e "${YELLOW}Agent Details:${NC}\n"
    
    for agent_file in "$AGENTS_DIR"/*.md; do
        if [[ $(basename "$agent_file") != "README.md" ]]; then
            agent_name=$(basename "$agent_file" .md | sed 's/-agent$//' | sed 's/-/ /g')
            agent_name=$(echo "$agent_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
            
            echo -e "${GREEN}▸ $agent_name${NC}"
            echo "  File: $(basename "$agent_file")"
            echo "  $(get_agent_description "$agent_file")"
            echo ""
        fi
    done
    
    echo -n "Press Enter to return to menu..."
    read -r
    select_agent
}

# Main execution
main() {
    # Check if agents directory exists
    if [ ! -d "$AGENTS_DIR" ]; then
        echo -e "${RED}Error: Agents directory not found at $AGENTS_DIR${NC}"
        echo "Creating directory..."
        mkdir -p "$AGENTS_DIR"
    fi
    
    # Check if any agents exist
    if [ -z "$(find "$AGENTS_DIR" -maxdepth 1 -name "*.md" -type f | grep -v README)" ]; then
        echo -e "${YELLOW}No agents found in $AGENTS_DIR${NC}"
        echo "Please add agent definition files (*.md) to this directory"
        exit 1
    fi
    
    select_agent
}

# Run the main function
main