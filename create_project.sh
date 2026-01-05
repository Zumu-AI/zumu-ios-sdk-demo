#!/bin/bash

# Create temporary directory for project generation
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Create project using xcodegen config
cat > project.yml << 'EOF'
name: DriverAppTranslatorDemo
options:
  bundleIdPrefix: com.driver.translator
  deploymentTarget:
    iOS: "15.0"
targets:
  DriverAppTranslatorDemo:
    type: application
    platform: iOS
    sources:
      - path: Sources
    settings:
      base:
        INFOPLIST_FILE: Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.driver.translator.demo
        MARKETING_VERSION: "1.0"
        CURRENT_PROJECT_VERSION: "1"
        SWIFT_VERSION: "5.0"
        TARGETED_DEVICE_FAMILY: "1,2"
        ENABLE_PREVIEWS: YES
    dependencies:
      - package: ZumuSDK
packages:
  ZumuSDK:
    url: https://github.com/Zumu-AI/zumu-ios-sdk
    from: "1.0.0"
EOF

echo "Project config created. You'll need to use Xcode GUI to create the project."
echo "Opening Xcode now..."
