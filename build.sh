#!/bin/bash

# Mole Heist Build Script
# Builds the game for macOS, Windows, and Linux

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Find Godot executable
GODOT=""
if command -v godot &> /dev/null; then
    GODOT="godot"
elif command -v godot4 &> /dev/null; then
    GODOT="godot4"
elif [ -f "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
elif [ -f "/usr/local/bin/godot" ]; then
    GODOT="/usr/local/bin/godot"
else
    echo -e "${RED}Error: Godot executable not found${NC}"
    echo "Please install Godot 4.4+ or add it to PATH"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Mole Heist - Build Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Using Godot: $GODOT"
echo ""

# Check for export templates
check_templates() {
    TEMPLATE_DIR="$HOME/Library/Application Support/Godot/export_templates/4.4.1.stable"
    if [ ! -d "$TEMPLATE_DIR" ]; then
        echo -e "${YELLOW}Warning: Export templates not found at:${NC}"
        echo "$TEMPLATE_DIR"
        echo ""
        echo "Please install export templates:"
        echo "1. Open Godot Editor"
        echo "2. Go to Editor → Manage Export Templates"
        echo "3. Click 'Download and Install'"
        echo ""
        echo "Or download manually from:"
        echo "https://godotengine.org/download/4.x/"
        echo ""
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Create build directories
create_dirs() {
    echo -e "${BLUE}Creating build directories...${NC}"
    mkdir -p builds/{macos,windows,linux}
}

# Build macOS
build_macos() {
    echo -e "${BLUE}Building for macOS...${NC}"
    $GODOT --headless --export-release "macOS" "builds/macos/MoleHeist.zip" 2>&1 | grep -v "^[[:space:]]*$" || true

    if [ -f "builds/macos/MoleHeist.zip" ]; then
        SIZE=$(du -h "builds/macos/MoleHeist.zip" | cut -f1)
        echo -e "${GREEN}✓ macOS build complete: builds/macos/MoleHeist.zip ($SIZE)${NC}"
    else
        echo -e "${RED}✗ macOS build failed${NC}"
        return 1
    fi
}

# Build Windows
build_windows() {
    echo -e "${BLUE}Building for Windows...${NC}"
    $GODOT --headless --export-release "Windows Desktop" "builds/windows/MoleHeist.exe" 2>&1 | grep -v "^[[:space:]]*$" || true

    if [ -f "builds/windows/MoleHeist.exe" ]; then
        SIZE=$(du -h "builds/windows/MoleHeist.exe" | cut -f1)
        echo -e "${GREEN}✓ Windows build complete: builds/windows/MoleHeist.exe ($SIZE)${NC}"
    else
        echo -e "${RED}✗ Windows build failed${NC}"
        return 1
    fi
}

# Build Linux
build_linux() {
    echo -e "${BLUE}Building for Linux...${NC}"
    $GODOT --headless --export-release "Linux" "builds/linux/MoleHeist.x86_64" 2>&1 | grep -v "^[[:space:]]*$" || true

    if [ -f "builds/linux/MoleHeist.x86_64" ]; then
        chmod +x "builds/linux/MoleHeist.x86_64"
        SIZE=$(du -h "builds/linux/MoleHeist.x86_64" | cut -f1)
        echo -e "${GREEN}✓ Linux build complete: builds/linux/MoleHeist.x86_64 ($SIZE)${NC}"
    else
        echo -e "${RED}✗ Linux build failed${NC}"
        return 1
    fi
}

# Clean builds
clean() {
    echo -e "${BLUE}Cleaning build directories...${NC}"
    rm -rf builds/
    echo -e "${GREEN}✓ Build directories cleaned${NC}"
}

# Show usage
usage() {
    echo "Usage: $0 [macos|windows|linux|all|clean]"
    echo ""
    echo "Options:"
    echo "  macos    - Build for macOS (Universal)"
    echo "  windows  - Build for Windows (x86_64)"
    echo "  linux    - Build for Linux (x86_64)"
    echo "  all      - Build for all platforms"
    echo "  clean    - Remove build directories"
    echo ""
    echo "Examples:"
    echo "  $0 macos"
    echo "  $0 all"
}

# Main
main() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    case "$1" in
        macos)
            check_templates
            create_dirs
            build_macos
            ;;
        windows)
            check_templates
            create_dirs
            build_windows
            ;;
        linux)
            check_templates
            create_dirs
            build_linux
            ;;
        all)
            check_templates
            create_dirs
            echo ""
            build_macos
            echo ""
            build_windows
            echo ""
            build_linux
            echo ""
            echo -e "${BLUE}========================================${NC}"
            echo -e "${GREEN}All builds complete!${NC}"
            echo -e "${BLUE}========================================${NC}"
            echo ""
            ls -lh builds/macos/MoleHeist.zip 2>/dev/null || echo "macOS build not found"
            ls -lh builds/windows/MoleHeist.exe 2>/dev/null || echo "Windows build not found"
            ls -lh builds/linux/MoleHeist.x86_64 2>/dev/null || echo "Linux build not found"
            ;;
        clean)
            clean
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
