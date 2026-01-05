#!/bin/bash

set -e

PROJECT_DIR="/Users/maximmakarenko/vektor-dev/driver-app-translator-demo"
cd "$PROJECT_DIR"

echo "🚀 Starting automated Xcode project setup..."

# Close Xcode if running
osascript <<EOF
tell application "Xcode"
    if it is running then
        quit
    end if
end tell
EOF

sleep 2

echo "📱 Creating new Xcode project..."

# Use osascript to automate Xcode project creation
osascript <<EOF
tell application "Xcode"
    activate
    delay 2
end tell

tell application "System Events"
    tell process "Xcode"
        -- Click "Create New Project" if welcome screen appears
        set frontmost to true
        delay 1

        -- Try to find and click "Create New Project" button
        try
            click button "Create New Project" of window 1
            delay 2
        on error
            -- If no welcome screen, use File menu
            click menu item "New" of menu "File" of menu bar 1
            delay 0.5
            click menu item "Project..." of menu "New" of menu "File" of menu bar 1
            delay 2
        end try

        -- Select iOS
        click button "iOS" of toolbar 1 of window 1
        delay 1

        -- Select App template (usually first in list)
        click UI element 1 of row 1 of outline 1 of scroll area 1 of window 1
        delay 1

        -- Click Next
        click button "Next" of window 1
        delay 2

        -- Fill in project details
        set value of text field 1 of window 1 to "DriverAppTranslatorDemo"
        delay 0.5

        -- Select SwiftUI interface (usually default)
        -- Click Next
        click button "Next" of window 1
        delay 2

        -- Save dialog - enter path
        keystroke "g" using {command down, shift down}
        delay 1

        set value of text field 1 of sheet 1 of window 1 to "$PROJECT_DIR"
        delay 0.5

        click button "Go" of sheet 1 of window 1
        delay 1

        -- Click Create
        click button "Create" of window 1
        delay 3
    end tell
end tell
EOF

echo "✅ Xcode project created!"
echo "⏳ Waiting for Xcode to finish loading..."
sleep 5

echo "🎉 Project setup complete!"
echo "📍 Project location: $PROJECT_DIR/DriverAppTranslatorDemo.xcodeproj"
