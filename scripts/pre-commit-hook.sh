#!/bin/bash
# Pre-commit hook to prevent accidental commit of sensitive files
# Place this in: .git/hooks/pre-commit
# Make executable: chmod +x .git/hooks/pre-commit

set -e

echo "🔐 Checking for sensitive files..."

SENSITIVE_FILES=(
    "lib/firebase_options.dart"
    "android/app/google-services.json"
    "ios/Runner/GoogleService-Info.plist"
    "web/firebase-config.json"
    ".env"
    ".env.local"
    "*.key"
    "*.pem"
)

EXIT_CODE=0

for file in "${SENSITIVE_FILES[@]}"; do
    if git diff --cached --name-only | grep -E "^${file}$"; then
        echo "❌ ERROR: Attempting to commit sensitive file: $file"
        echo "   This file contains API keys and credentials!"
        echo "   Add it to .gitignore or remove from staging"
        EXIT_CODE=1
    fi
done

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ No sensitive files detected"
fi

exit $EXIT_CODE
