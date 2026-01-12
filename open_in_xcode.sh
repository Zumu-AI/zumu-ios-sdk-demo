#!/bin/bash

# Quick script to open the Xcode project

echo "🚀 Opening Zumu SDK Button Demo in Xcode..."
echo ""
echo "📁 Project: DriverAppTranslatorDemo.xcodeproj"
echo "📍 Location: $(pwd)/xcode-folder/DriverAppTranslatorDemo/"
echo ""

cd xcode-folder/DriverAppTranslatorDemo
open DriverAppTranslatorDemo.xcodeproj

echo "✅ Xcode should open shortly"
echo ""
echo "Next steps:"
echo "1. File → Packages → Reset Package Caches"
echo "2. File → Packages → Resolve Package Versions"
echo "3. Cmd+Shift+K (Clean)"
echo "4. Cmd+B (Build)"
echo "5. Cmd+R (Run)"
