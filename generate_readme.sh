#!/usr/bin/env bash

# Configuration
IMAGES_PER_PAGE=10
COLUMNS=3
IMAGE_WIDTH=300

# Check if we're in the right directory
if [ ! -d ".git" ]; then
    echo "⚠️  Warning: Not in a git repository. Make sure you're in the right directory."
fi

echo "🎨 Generating paginated wallpaper gallery..."

# Get all image files sorted (with better error handling)
echo "🔍 Scanning for images..."
mapfile -t images < <(find . -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.webp" \) 2>/dev/null | sort -V)

total_images=${#images[@]}
if [ $total_images -eq 0 ]; then
    echo "❌ No images found in current directory!"
    echo "   Make sure you have image files (.png, .jpg, .jpeg, .gif, .webp) in this folder."
    exit 1
fi

# Calculate total pages
total_pages=$(( (total_images + IMAGES_PER_PAGE - 1) / IMAGES_PER_PAGE ))

echo "Found $total_images images, creating $total_pages pages..."

# Function to generate navigation
generate_navigation() {
    local current_page=$1
    local total_pages=$2
    local filename=$3

    echo "" >> "$filename"
    echo "---" >> "$filename"
    echo "" >> "$filename"
    echo "<div align=\"center\">" >> "$filename"
    echo "" >> "$filename"

    # Previous button
    if [ $current_page -gt 1 ]; then
        local prev_page=$((current_page - 1))
        if [ $prev_page -eq 1 ]; then
            echo "  <a href=\"README.md\">← Previous</a>" >> "$filename"
        else
            echo "  <a href=\"README-page-$prev_page.md\">← Previous</a>" >> "$filename"
        fi
    else
        echo "  <span style=\"color: #ccc;\">← Previous</span>" >> "$filename"
    fi

    echo "  &nbsp;&nbsp;&nbsp;" >> "$filename"

    # Page indicator
    echo "  <strong>Page $current_page of $total_pages</strong>" >> "$filename"

    echo "  &nbsp;&nbsp;&nbsp;" >> "$filename"

    # Next button
    if [ $current_page -lt $total_pages ]; then
        local next_page=$((current_page + 1))
        echo "  <a href=\"README-page-$next_page.md\">Next →</a>" >> "$filename"
    else
        echo "  <span style=\"color: #ccc;\">Next →</span>" >> "$filename"
    fi

    echo "" >> "$filename"
    echo "</div>" >> "$filename"
    echo "" >> "$filename"

    # Page numbers
    echo "<div align=\"center\">" >> "$filename"
    echo "  <small>" >> "$filename"
    echo -n "    Pages: " >> "$filename"

    for ((p=1; p<=total_pages; p++)); do
        if [ $p -eq $current_page ]; then
            echo -n "<strong>$p</strong>" >> "$filename"
        else
            if [ $p -eq 1 ]; then
                echo -n "<a href=\"README.md\">$p</a>" >> "$filename"
            else
                echo -n "<a href=\"README-page-$p.md\">$p</a>" >> "$filename"
            fi
        fi

        if [ $p -lt $total_pages ]; then
            echo -n " • " >> "$filename"
        fi
    done

    echo "" >> "$filename"
    echo "  </small>" >> "$filename"
    echo "</div>" >> "$filename"
}

# Function to generate header
generate_header() {
    local current_page=$1
    local total_pages=$2
    local filename=$3

    {
        echo "# 🖼️ Wallpaper Gallery"
        echo ""
        if [ $total_pages -gt 1 ]; then
            echo "*Showing page $current_page of $total_pages ($total_images total wallpapers)*"
            echo ""
        else
            echo "*$total_images beautiful wallpapers*"
            echo ""
        fi
        echo "---"
        echo ""
    } > "$filename"
}

# Function to generate table
generate_table() {
    local start_idx=$1
    local end_idx=$2
    local filename=$3

    echo "<table align=\"center\">" >> "$filename"

    local count=0
    local row_open=false

    for ((i=start_idx; i<=end_idx && i<total_images; i++)); do
        local img="${images[i]}"
        local img_clean="${img#./}"  # remove leading ./
        local img_name=$(basename "$img_clean" | sed 's/\.[^.]*$//')  # filename without extension

        if (( count % COLUMNS == 0 )); then
            echo "  <tr>" >> "$filename"
            row_open=true
        fi

        echo "    <td align=\"center\" width=\"${IMAGE_WIDTH}px\">" >> "$filename"
        echo "      <img src=\"$img_clean\" width=\"${IMAGE_WIDTH}px\" alt=\"$img_name\"><br>" >> "$filename"
        echo "      <small><em>$img_name</em></small>" >> "$filename"
        echo "    </td>" >> "$filename"

        ((count++))

        if (( count % COLUMNS == 0 )); then
            echo "  </tr>" >> "$filename"
            row_open=false
        fi
    done

    # Close last row if needed
    if $row_open; then
        # Fill empty cells if needed
        while (( count % COLUMNS != 0 )); do
            echo "    <td></td>" >> "$filename"
            ((count++))
        done
        echo "  </tr>" >> "$filename"
    fi

    echo "</table>" >> "$filename"
}

# Generate pages
for ((page=1; page<=total_pages; page++)); do
    start_idx=$(( (page - 1) * IMAGES_PER_PAGE ))
    end_idx=$(( start_idx + IMAGES_PER_PAGE - 1 ))

    if [ $page -eq 1 ]; then
        filename="README.md"
    else
        filename="README-page-$page.md"
    fi

    echo "Generating $filename..."

    # Generate header
    generate_header $page $total_pages "$filename"

    # Add navigation at top for pages > 1
    if [ $total_pages -gt 1 ]; then
        generate_navigation $page $total_pages "$filename"
        echo "" >> "$filename"
    fi

    # Generate table
    generate_table $start_idx $end_idx "$filename"

    # Add navigation at bottom
    if [ $total_pages -gt 1 ]; then
        generate_navigation $page $total_pages "$filename"
    fi

    # Add footer
    echo "" >> "$filename"
    echo "---" >> "$filename"
    echo "<div align=\"center\">" >> "$filename"
    echo "  <small>Generated automatically with the wallpaper gallery script</small>" >> "$filename"
    echo "</div>" >> "$filename"
done

# Generate index file with all pages listed
if [ $total_pages -gt 1 ]; then
    echo "Generating INDEX.md..."
    {
        echo "# 📁 Wallpaper Gallery Index"
        echo ""
        echo "This gallery contains **$total_images wallpapers** across **$total_pages pages**."
        echo ""
        echo "## 📄 Pages"
        echo ""
        for ((page=1; page<=total_pages; page++)); do
            start_img=$(( (page - 1) * IMAGES_PER_PAGE + 1 ))
            end_img=$(( page * IMAGES_PER_PAGE ))
            if [ $end_img -gt $total_images ]; then
                end_img=$total_images
            fi

            if [ $page -eq 1 ]; then
                echo "- **[Page $page](README.md)** - Wallpapers $start_img-$end_img"
            else
                echo "- **[Page $page](README-page-$page.md)** - Wallpapers $start_img-$end_img"
            fi
        done
        echo ""
        echo "---"
        echo ""
        echo "### 🎨 Quick Stats"
        echo "- **Total Images:** $total_images"
        echo "- **Images per Page:** $IMAGES_PER_PAGE"
        echo "- **Total Pages:** $total_pages"
        echo "- **Supported Formats:** PNG, JPG, JPEG, GIF, WebP"
        echo ""
        echo "<div align=\"center\">"
        echo "  <a href=\"README.md\">🚀 Start Browsing</a>"
        echo "</div>"
    } > INDEX.md
fi

echo ""
echo "✅ Gallery generation complete!"
echo "📊 Statistics:"
echo "   - Total images: $total_images"
echo "   - Pages created: $total_pages"
echo "   - Images per page: $IMAGES_PER_PAGE"
echo ""
if [ $total_pages -gt 1 ]; then
    echo "📄 Files created:"
    echo "   - README.md (Page 1)"
    for ((page=2; page<=total_pages; page++)); do
        echo "   - README-page-$page.md"
    done
    echo "   - INDEX.md (Overview)"
    echo ""
    echo "🎯 Start here: README.md or INDEX.md"
else
    echo "📄 File created: README.md"
fi
