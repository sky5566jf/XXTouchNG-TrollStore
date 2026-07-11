#!/bin/bash

# XXTouchNG TrollStore Build Script
# This script builds XXTouchNG and packages as .tipa for TrollStore

set -e

APP_NAME="XXTouchNG"
BUNDLE_ID="ch.xxtou.xxtouchng"
VERSION="3.0.1"

echo "=== XXTouchNG TrollStore Build ==="
echo ""

# Check for required tools
if ! command -v make &> /dev/null; then
    echo "Error: make not found. Please install Xcode Command Line Tools."
    exit 1
fi

if ! command -v ldid &> /dev/null; then
    echo "Error: ldid not found. Please install ldid (brew install ldid)."
    exit 1
fi

if ! command -v zip &> /dev/null; then
    echo "Error: zip not found."
    exit 1
fi

# Check for theos
if [ -z "$THEOS" ]; then
    echo "Error: THEOS environment variable not set."
    echo "Please install theos: https://theos.dev/docs/installation"
    exit 1
fi

echo "Building XXTouchNG for TrollStore..."
echo ""

# Clean previous builds
make clean 2>/dev/null || true
rm -rf build_tipa
rm -f ${APP_NAME}.tipa

# Build all modules
export FINALPACKAGE=1
export TARGET_CODESIGN=ldid

echo "[1/4] Building modules..."
make FINALPACKAGE=1 -j$(sysctl -n hw.ncpu)

echo ""
echo "[2/4] Creating app bundle structure..."

# Create Payload directory structure
mkdir -p build_tipa/Payload/${APP_NAME}.app
mkdir -p build_tipa/Payload/${APP_NAME}.app/Frameworks
mkdir -p build_tipa/Payload/${APP_NAME}.app/bin
mkdir -p build_tipa/Payload/${APP_NAME}.app/lib

# Copy built binaries
echo "[3/4] Copying binaries..."

# Copy dylibs
for lib in $(find . -name "*.dylib" -path "*/layout/usr/local/lib/*"); do
    base=$(basename "$lib")
    echo "  Copying $base"
    cp "$lib" build_tipa/Payload/${APP_NAME}.app/lib/
done

# Copy CLI tools
for tool in $(find . -type f -executable -path "*/layout/usr/local/xxtouch/bin/*"); do
    base=$(basename "$tool")
    echo "  Copying $base"
    cp "$tool" build_tipa/Payload/${APP_NAME}.app/bin/
done

# Copy Lua scripts and resources
if [ -d "ext/layout/usr/local/xxtouch" ]; then
    echo "  Copying xxtouch resources"
    cp -R ext/layout/usr/local/xxtouch/* build_tipa/Payload/${APP_NAME}.app/
fi

# Create Info.plist
cat > build_tipa/Payload/${APP_NAME}.app/Info.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleDisplayName</key>
    <string>XXTouchNG</string>
    <key>CFBundleExecutable</key>
    <string>webserv</string>
    <key>CFBundleIdentifier</key>
    <string>ch.xxtou.xxtouchng</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>XXTouchNG</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>3.0.1</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>MinimumOSVersion</key>
    <string>14.0</string>
    <key>UIDeviceFamily</key>
    <array>
        <integer>1</integer>
    </array>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
</dict>
</plist>
PLIST

# Create entitlements for TrollStore
cat > build_tipa/Payload/${APP_NAME}.app/${APP_NAME}.entitlements << 'ENT'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>platform-application</key>
    <true/>
    <key>get-task-allow</key>
    <true/>
    <key>task_for_pid-allow</key>
    <true/>
    <key>proc_info-allow</key>
    <true/>
    <key>run-unsigned-code</key>
    <true/>
    <key>com.apple.private.security.no-sandbox</key>
    <true/>
    <key>com.apple.private.security.no-container</key>
    <true/>
    <key>com.apple.private.skip-library-validation</key>
    <true/>
    <key>com.apple.private.kernel.jetsam</key>
    <true/>
    <key>com.apple.private.hid.manager.client</key>
    <true/>
    <key>com.apple.private.hid.client.event-dispatch</key>
    <true/>
    <key>com.apple.private.hid.client.event-monitor</key>
    <true/>
    <key>com.apple.private.IOSurface.protected-access</key>
    <true/>
    <key>com.apple.security.iokit-user-client-class</key>
    <array>
        <string>IOSurfaceRootUserClient</string>
        <string>IOMobileFramebufferUserClient</string>
        <string>IOSurfaceAcceleratorClient</string>
        <string>IOHIDLibUserClient</string>
    </array>
</dict>
</plist>
ENT

# Sign the executable
echo "[4/4] Signing..."
cd build_tipa/Payload/${APP_NAME}.app
ldid -S${APP_NAME}.entitlements webserv 2>/dev/null || true
cd ../../..

# Create .tipa (which is just a zip)
echo ""
echo "Creating .tipa package..."
cd build_tipa
zip -r ../${APP_NAME}.tipa Payload/
cd ..

# Cleanup
rm -rf build_tipa

echo ""
echo "=== Build Complete ==="
echo ""
echo "Output: ${APP_NAME}.tipa"
echo ""
echo "To install via TrollStore:"
echo "1. Copy ${APP_NAME}.tipa to your device"
echo "2. Open TrollStore"
echo "3. Tap + and select ${APP_NAME}.tipa"
echo "4. Install"
echo ""
