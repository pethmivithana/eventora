#!/bin/bash

# Eventora - Quick Start Script
# This script sets up the Flutter project and runs it

echo "========================================="
echo "   Eventora - Quick Start Setup"
echo "========================================="
echo ""

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Flutter is installed
echo -e "${YELLOW}Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed!${NC}"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi
echo -e "${GREEN}✅ Flutter found: $(flutter --version)${NC}"
echo ""

# Check if in correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ pubspec.yaml not found!${NC}"
    echo "Please run this script from the eventora project root directory"
    exit 1
fi
echo -e "${GREEN}✅ Found pubspec.yaml${NC}"
echo ""

# Step 1: Clean and get dependencies
echo -e "${YELLOW}Step 1: Cleaning and fetching dependencies...${NC}"
flutter clean
flutter pub get
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
else
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi
echo ""

# Step 2: Check Firebase setup
echo -e "${YELLOW}Step 2: Checking Firebase configuration...${NC}"
if [ -f "android/app/google-services.json" ]; then
    echo -e "${GREEN}✅ Android Firebase config found${NC}"
else
    echo -e "${YELLOW}⚠️  android/app/google-services.json not found${NC}"
    echo "   Download from Firebase Console → Project Settings → Android"
    echo "   See SETUP_AND_RUN.md for detailed instructions"
fi

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${GREEN}✅ iOS Firebase config found${NC}"
else
    echo -e "${YELLOW}⚠️  iOS Firebase config not found (optional for iOS)${NC}"
fi
echo ""

# Step 3: List available devices
echo -e "${YELLOW}Step 3: Available devices:${NC}"
flutter devices
echo ""

# Step 4: Run the app
echo -e "${YELLOW}Step 4: Starting Eventora app...${NC}"
echo "Make sure you have:"
echo "  1. An emulator running, OR"
echo "  2. A physical device connected via USB (enable USB debugging)"
echo ""
echo -e "${GREEN}Running: flutter run${NC}"
echo ""

flutter run

# Check if run was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ App launched successfully!${NC}"
    echo ""
    echo "Tips while running:"
    echo "  - Press 'r' to hot reload"
    echo "  - Press 'Shift+r' to hot restart"
    echo "  - Press 'q' to quit"
else
    echo -e "${RED}❌ Failed to run app${NC}"
    echo "Check the output above for errors"
    exit 1
fi
