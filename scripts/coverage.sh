#!/bin/bash

# Check if lcov is installed
if ! command -v lcov &> /dev/null; then
    echo "Error: lcov is not installed."
    echo "Install it with: brew install lcov (macOS) or sudo apt-get install lcov (Linux)"
    exit 1
fi

# Run tests with coverage
flutter test --coverage

# Optional: Generate HTML report
genhtml coverage/lcov.info -o coverage/html

echo "Coverage report generated at coverage/html/index.html"
