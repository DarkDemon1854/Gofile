#!/bin/bash
# Function to install packages (without sudo)
install_package() {
    PACKAGE=$1
    if ! command -v $PACKAGE &> /dev/null; then
        echo "$PACKAGE is not installed. Attempting installation..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # For Debian/Ubuntu-based systems
            apt-get update && apt-get install -y $PACKAGE || {
                echo "Failed to install $PACKAGE. Please install it manually."
                exit 1
            }
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # For macOS
            brew install $PACKAGE || {
                echo "Failed to install $PACKAGE. Please install it manually."
                exit 1
            }
        else
            echo "Unsupported OS or insufficient privileges. Please install $PACKAGE manually."
            exit 1
        fi
    else
        echo "$PACKAGE is already installed."
    fi
}

# Check and install curl and jq if not installed
install_package "curl"
install_package "jq"

# Check if a file argument is provided
if [[ "$#" == '0' ]]; then
    echo -e 'ERROR: No File Specified!' && exit 1
fi

# Store the file path, preserving spaces
FILE="$1"

# Query GoFile API to find the best server for upload
SERVER=$(curl -s https://api.gofile.io/servers | jq -r '.data.servers[0].name')

# Upload the file to GoFile
LINK=$(curl -# -F "file=@$FILE" "https://${SERVER}.gofile.io/uploadFile" | jq -r '.data|.downloadPage') 2>&1

# Display the download link
echo "$LINK"
echo
