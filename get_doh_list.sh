#!/bin/bash

# URL to fetch the raw wiki content
URL="https://raw.githubusercontent.com/wiki/curl/curl/DNS-over-HTTPS.md"
# Temporary file to store the downloaded content
TEMP_FILE="DNS-over-HTTPS.md"

# Download the content from the URL
curl -o $TEMP_FILE $URL

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Failed to download the file from $URL"
    exit 1
fi

# Process the content and extract the required information
CONTENT=$(sed -n '/^# Publicly available servers/,/^# Private DNS Server/p' $TEMP_FILE | \
    grep "^|" | tail -n +3 | \
    sed 's/^|// ; s/^[ ]*// ; s/^[^|]*|// ; s/^[ ]*// ; /^\*\*/d ; s/|.*//' | \
    grep -o 'https://[a-zA-Z0-9./?=_%:-]*' | \
    awk -F[/:] '{ print $4 }')

# Create the output file
cat << EOF > doh-list.txt
#$(sha256sum $TEMP_FILE | cut -d' ' -f1)
#
# DNS-over-HTTPS Providers
# Compiled from curl/curl wiki
#
# POTENTIAL PROBLEM DOMAINS:
#   !!! These DoT resolvers are at a base url, so blocking these providers
#   !!! may block regular web access to these services.
#
$(echo "$CONTENT" | awk -F'.' 'NF==2' | awk '{ print "#\t" $0}')
#

$CONTENT
EOF

# Clean up temporary file
rm $TEMP_FILE

echo "The list has been compiled and saved to doh-list.txt"
