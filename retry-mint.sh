#!/bin/bash

# Configuration
MAX_RETRIES=300
WAIT_TIME=60  # seconds between retries
ADDRESS="DDtXNPQZavxmRnbtEs7FLrtKuijXna4Fbx"
FILE="megaphone.glb"

echo "Starting Doginal minting retry script..."

attempt=1
success=false

while [ $attempt -le $MAX_RETRIES ] && [ "$success" = false ]; do
    echo "Attempt $attempt of $MAX_RETRIES"
    
    # Run the minting command
    output=$(node . mint $ADDRESS $FILE 2>&1)
    
    # Check if the command completed successfully
    if ! echo "$output" | grep -q "too-long-mempool-chain"; then
        if echo "$output" | grep -q "broadcasting tx .* of"; then
            echo "Minting appears to be progressing..."
        else
            echo "Minting completed successfully!"
            success=true
            break
        fi
    else
        echo "Hit mempool chain limit, waiting $WAIT_TIME seconds before retry..."
        echo "Last output was:"
        echo "$output" | tail -n 5
    fi
    
    # Wait before next attempt
    sleep $WAIT_TIME
    
    # Increment attempt counter
    ((attempt++))
done

if [ "$success" = false ]; then
    echo "Failed to complete minting after $MAX_RETRIES attempts"
    exit 1
else
    echo "Minting process completed successfully"
    exit 0
fi