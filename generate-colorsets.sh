#!/bin/bash

# Script to generate Xcode .colorset files from JSON color definitions
# Usage: ./generate-colorsets.sh input.json [output_directory]

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_json_file> [output_directory]"
    echo "Example: $0 colors.json ./ColorSets"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_DIR="${2:-.}"  # Default to current directory if not specified

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to convert hex to decimal
hex_to_decimal() {
    local hex="$1"
    # Remove # if present
    hex="${hex#\#}"
    echo "ibase=16; ${hex^^}" | bc
}

# Function to convert RGB values to hex format for colorset
rgb_to_hex_components() {
    local rgb_string="$1"
    # Extract R, G, B values from "R, G, B" format
    local r=$(echo "$rgb_string" | cut -d',' -f1 | tr -d ' ')
    local g=$(echo "$rgb_string" | cut -d',' -f2 | tr -d ' ')
    local b=$(echo "$rgb_string" | cut -d',' -f3 | tr -d ' ')
    
    # Convert to hex format (0xXX)
    printf "0x%02X" "$r"
    echo -n " "
    printf "0x%02X" "$g" 
    echo -n " "
    printf "0x%02X" "$b"
}

# Function to create colorset file
create_colorset() {
    local color_name="$1"
    local light_rgb="$2"
    local dark_rgb="$3"
    local alpha="${4:-1.000}"
    
    # Convert RGB to hex components
    local light_components=($(rgb_to_hex_components "$light_rgb"))
    local dark_components=($(rgb_to_hex_components "$dark_rgb"))
    
    local colorset_dir="$OUTPUT_DIR/${color_name}.colorset"
    mkdir -p "$colorset_dir"
    
    # Create Contents.json file
    cat > "$colorset_dir/Contents.json" << EOF
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "$alpha",
          "blue" : "${light_components[2]}",
          "green" : "${light_components[1]}",
          "red" : "${light_components[0]}"
        }
      },
      "idiom" : "universal"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "$alpha",
          "blue" : "${dark_components[2]}",
          "green" : "${dark_components[1]}",
          "red" : "${dark_components[0]}"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    
    echo "Created: $colorset_dir/Contents.json"
}

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Please install jq: brew install jq (on macOS) or apt-get install jq (on Ubuntu)"
    exit 1
fi

# Parse JSON and create colorset files
echo "Generating .colorset files from $INPUT_FILE..."
echo "Output directory: $OUTPUT_DIR"
echo ""

# Extract colors array and process each color
jq -r '.colors[] | @base64' "$INPUT_FILE" | while read -r color_data; do
    # Decode base64 and extract color information
    color_json=$(echo "$color_data" | base64 --decode)
    
    name=$(echo "$color_json" | jq -r '.name')
    light_rgb=$(echo "$color_json" | jq -r '.light.rgb')
    dark_rgb=$(echo "$color_json" | jq -r '.dark.rgb')
    
    # Check if alpha is specified
    alpha=$(echo "$color_json" | jq -r '.light.alpha // "1.000"')
    
    # Handle special case for shadow colors with alpha
    if [ "$name" = "ShadowColor" ]; then
        alpha=$(echo "$color_json" | jq -r '.light.alpha // "0.08"')
    fi
    
    echo "Processing: $name"
    create_colorset "$name" "$light_rgb" "$dark_rgb" "$alpha"
done

echo ""
echo "✅ Color generation complete!"
echo "📁 Generated files in: $OUTPUT_DIR"
echo ""
echo "To use in Xcode:"
echo "1. Drag the generated .colorset folders into your app's Asset Catalog"
echo "2. Use in SwiftUI: Color(\"$name\")"
echo "3. Use in UIKit: UIColor(named: \"$name\")"