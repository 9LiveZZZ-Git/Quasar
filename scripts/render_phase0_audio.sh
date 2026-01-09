#!/bin/bash

# ==============================================================================
# Quasar Phase 0 Audio Rendering Script
# ==============================================================================
#
# This script automates the rendering of Phase 0 DnB proof of concept
# compositions to .wav files.
#
# Usage:
#   ./render_phase0_audio.sh
#
# Requirements:
#   - SuperCollider 3.13.0+ installed
#   - sclang in PATH
#   - Quasar project properly installed
#
# Output:
#   - .wav files in examples/compositions/audio/
#   - Rendering logs in examples/compositions/audio/logs/
#
# ==============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EXAMPLES_DIR="$PROJECT_ROOT/examples"
OUTPUT_DIR="$EXAMPLES_DIR/compositions/audio"
LOG_DIR="$OUTPUT_DIR/logs"

# ==============================================================================
# Helper Functions
# ==============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}=============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=============================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# ==============================================================================
# Check Prerequisites
# ==============================================================================

check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check if sclang is available
    if ! command -v sclang &> /dev/null; then
        print_error "SuperCollider (sclang) not found in PATH"
        echo ""
        echo "Please install SuperCollider 3.13.0 or later:"
        echo "  - macOS: brew install supercollider"
        echo "  - Linux: apt-get install supercollider"
        echo "  - Or download from: https://supercollider.github.io"
        echo ""
        echo "Alternative: Run the rendering script manually in SuperCollider IDE"
        echo "  1. Open SuperCollider IDE"
        echo "  2. Load: $EXAMPLES_DIR/PHASE_0_RENDER_TO_AUDIO.scd"
        echo "  3. Execute the script"
        echo ""
        exit 1
    fi

    print_success "SuperCollider found: $(sclang -version 2>&1 | head -n1)"

    # Check if project structure exists
    if [ ! -d "$PROJECT_ROOT/src" ]; then
        print_error "Project structure not found"
        echo "Please run this script from the Quasar project root"
        exit 1
    fi

    print_success "Project structure verified"

    # Check if SynthDefs exist
    if [ ! -f "$PROJECT_ROOT/resources/SynthDefs/dnb_synthdefs.scd" ]; then
        print_error "SynthDefs not found"
        echo "Expected: $PROJECT_ROOT/resources/SynthDefs/dnb_synthdefs.scd"
        exit 1
    fi

    print_success "SynthDefs found"

    # Create output directories
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$LOG_DIR"
    print_success "Output directories ready"

    echo ""
}

# ==============================================================================
# Render Audio
# ==============================================================================

render_audio() {
    print_header "Rendering Phase 0 Audio"

    print_info "This will take approximately 6-8 minutes..."
    print_info "Output: $OUTPUT_DIR"
    echo ""

    # Check if rendering script exists
    if [ ! -f "$EXAMPLES_DIR/PHASE_0_RENDER_TO_AUDIO.scd" ]; then
        print_error "Rendering script not found"
        exit 1
    fi

    # Note about manual rendering
    print_warning "Automated command-line rendering requires SuperCollider server"
    print_warning "For best results, use SuperCollider IDE:"
    echo ""
    echo "  1. Boot SuperCollider server: s.boot;"
    echo "  2. Load script: load(\"$EXAMPLES_DIR/PHASE_0_RENDER_TO_AUDIO.scd\");"
    echo "  3. Wait for completion (~6-8 minutes)"
    echo ""

    read -p "Continue with command-line attempt? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cancelled. Please use SuperCollider IDE for rendering."
        exit 0
    fi

    # Attempt to run via sclang
    # Note: This may not work well due to server timing requirements
    print_info "Attempting command-line render..."

    cd "$EXAMPLES_DIR"
    sclang PHASE_0_RENDER_TO_AUDIO.scd 2>&1 | tee "$LOG_DIR/render_$(date +%Y%m%d_%H%M%S).log"

    echo ""
}

# ==============================================================================
# Verify Output
# ==============================================================================

verify_output() {
    print_header "Verifying Output"

    local files_found=0
    local expected_files=(
        "phase0_dnb_classic_seed_12345.wav"
        "phase0_dnb_aggressive_seed_42.wav"
        "phase0_dnb_smooth_seed_99999.wav"
    )

    for file in "${expected_files[@]}"; do
        if [ -f "$OUTPUT_DIR/$file" ]; then
            local size=$(du -h "$OUTPUT_DIR/$file" | cut -f1)
            print_success "Found: $file ($size)"
            ((files_found++))
        else
            print_warning "Missing: $file"
        fi
    done

    echo ""

    if [ $files_found -eq ${#expected_files[@]} ]; then
        print_success "All files rendered successfully!"
    elif [ $files_found -gt 0 ]; then
        print_warning "Partial success: $files_found/${#expected_files[@]} files rendered"
    else
        print_error "No files found. Rendering may have failed."
        echo ""
        echo "Please check the log file in: $LOG_DIR"
        echo "Or try manual rendering in SuperCollider IDE"
        exit 1
    fi

    echo ""
}

# ==============================================================================
# Generate Checksums
# ==============================================================================

generate_checksums() {
    print_header "Generating Checksums"

    if [ ! -f "$OUTPUT_DIR/phase0_dnb_classic_seed_12345.wav" ]; then
        print_warning "No files to checksum"
        return
    fi

    local checksum_file="$OUTPUT_DIR/checksums.txt"

    cd "$OUTPUT_DIR"
    sha256sum *.wav > "$checksum_file" 2>/dev/null || \
        shasum -a 256 *.wav > "$checksum_file" 2>/dev/null || \
        print_warning "Could not generate checksums (sha256sum/shasum not available)"

    if [ -f "$checksum_file" ]; then
        print_success "Checksums saved to: $checksum_file"
        echo ""
        cat "$checksum_file"
    fi

    echo ""
}

# ==============================================================================
# Print Summary
# ==============================================================================

print_summary() {
    print_header "Rendering Complete"

    echo "Output location:"
    echo "  $OUTPUT_DIR"
    echo ""

    echo "Files generated:"
    if [ -d "$OUTPUT_DIR" ]; then
        ls -lh "$OUTPUT_DIR"/*.wav 2>/dev/null || echo "  (No .wav files found)"
    fi
    echo ""

    echo "Next steps:"
    echo "  1. Listen to the generated files"
    echo "  2. Compare different seed variations"
    echo "  3. Verify reproducibility (same seed = identical file)"
    echo ""

    echo "Documentation:"
    echo "  - File info: $OUTPUT_DIR/README.md"
    echo "  - Manifest: $OUTPUT_DIR/manifest.json"
    echo "  - Instructions: $EXAMPLES_DIR/compositions/RENDER_INSTRUCTIONS.md"
    echo ""

    print_success "Phase 0 audio rendering complete!"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header "Quasar Phase 0 Audio Rendering"

    echo "This script will render Phase 0 DnB proof of concept to audio files."
    echo ""

    check_prerequisites

    print_warning "Note: Automated rendering may not work properly from command line."
    print_info "For reliable results, use SuperCollider IDE (see instructions above)."
    echo ""

    # For now, just show instructions rather than attempting automated render
    print_info "Manual Rendering Instructions:"
    echo ""
    echo "1. Open SuperCollider IDE"
    echo "2. Boot the server:"
    echo "   s.boot;"
    echo ""
    echo "3. Load and run the rendering script:"
    echo "   load(\"$EXAMPLES_DIR/PHASE_0_RENDER_TO_AUDIO.scd\");"
    echo ""
    echo "4. Wait for completion (~6-8 minutes)"
    echo ""
    echo "5. Find your files in:"
    echo "   $OUTPUT_DIR"
    echo ""

    print_success "Instructions displayed. Happy rendering!"
}

# Run main
main
