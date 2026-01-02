#!/usr/bin/env bash

# Version of the tool
VERSION="1.0.0"

# --- COLORS ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- INTRODUCTORY HEADER ---
echo -e "${BLUE}================================================================${NC}"
echo -e "TOOL:    format_code.sh (v$VERSION)${NC}"
echo -e "PURPOSE: Enforces C/C++ Linux Kernel coding standards."
echo -e "METHOD:  Automates 'indent -linux' with safety checks."
echo -e "USAGE:   Run with -h or --help to show the list of options."
echo -e "${BLUE}================================================================${NC}"

# Function to display usage and examples
show_help() {
    echo ""
    echo -e "${YELLOW}Usage:${NC} $(basename "$0") [OPTIONS] <target>"
    echo ""
    echo "Options:"
    echo "  -d, --dry-run    Preview files without changing them."
    echo "  -r, --recursive  Search subdirectories."
    echo "  -e, --examples   Show a real-world 'Before & After' example."
    echo "  -v, --version    Display script version."
    echo "  -h, --help       Display this help message."
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $(basename "$0") -r ./src            # Format whole project"
    echo "  $(basename "$0") -d ./scripts        # Preview folder changes"
    exit 0
}

# Function to show before/after code
show_examples() {
    echo -e "\n${BLUE}--- REAL WORLD EXAMPLE (Linux Kernel Style) ---${NC}"
    echo -e "\n${RED}BEFORE FORMATTING (Messy):${NC}"
    echo "--------------------------------"
    echo "int main(){"
    echo "int x=10;if(x>5){printf(\"hello\");}"
    echo "return 0;}"
    echo "--------------------------------"
    echo -e "\n${GREEN}AFTER FORMATTING (Clean):${NC}"
    echo "--------------------------------"
    echo "int main()"
    echo "{"
    echo "	int x = 10;"
    echo "	if (x > 5) {"
    echo "		printf(\"hello\");"
    echo "	}"
    echo "	return 0;"
    echo "}"
    echo "--------------------------------"
    exit 0
}

# Initialize Counters
SUCCESS_COUNT=0
FAILURE_COUNT=0
DRY_RUN=false
RECURSIVE=false
TARGET=""

# Parse flags
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)      show_help ;;
        -e|--examples)  show_examples ;;
        -v|--version)   echo "format_code.sh version $VERSION"; exit 0 ;;
        -d|--dry-run)   DRY_RUN=true ;;
        -r|--recursive) RECURSIVE=true ;;
        -*) echo -e "${RED}Unknown option: $1${NC}"; show_help ;;
        *) TARGET="$1" ;; 
    esac
    shift
done

if [ -z "$TARGET" ]; then
    echo -e "\n${RED}Error: No target provided. Use -h for help.${NC}"
    exit 1
fi

# Confirmation Warning
if [ "$DRY_RUN" = false ]; then
    echo -e "\n${YELLOW}WARNING: This will overwrite files in: $TARGET${NC}"
    read -p "Continue? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

format_file() {
    local file="$1"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} Would format: $file"
        ((SUCCESS_COUNT++))
    else
        if indent -linux "$file" -o "$file.tmp" && mv "$file.tmp" "$file"; then
            echo -e "${GREEN}[SUCCESS]${NC} Formatted: $file"
            ((SUCCESS_COUNT++))
        else
            echo -e "${RED}[ERROR]${NC} Failed to format: $file"
            ((FAILURE_COUNT++))
        fi
    fi
}

# Main Search Logic (Process Substitution)
if [ -d "$TARGET" ]; then
    DEPTH_FLAG="-maxdepth 1"
    [[ "$RECURSIVE" = true ]] && DEPTH_FLAG=""
    
    while IFS= read -r -d '' file; do
        format_file "$file"
    done < <(find "$TARGET" $DEPTH_FLAG -type f \( -name "*.c" -or -name "*.cpp" \) -print0)
elif [ -f "$TARGET" ]; then
    format_file "$TARGET"
else
    echo -e "${RED}Error: '$TARGET' is not a valid path.${NC}"
    exit 1
fi

# Final Summary
echo ""
echo -e "${BLUE}----------------------------------------------------------------${NC}"
echo -e "PROCESS COMPLETE"
echo -e "  Total ${GREEN}Successful${NC}: $SUCCESS_COUNT"
echo -e "  Total ${RED}Failures${NC}:   $FAILURE_COUNT"
echo -e "${BLUE}----------------------------------------------------------------${NC}"
