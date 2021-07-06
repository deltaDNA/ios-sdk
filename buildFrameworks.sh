#!/bin/bash

# Make sure the required directories are in place
if [ ! -d "$DIRECTORY" ]; then
    mkdir -p build/Frameworks
fi

# Create the separate frameworks
xcodebuild archive -workspace "DeltaDNA.xcworkspace" -scheme "DeltaDNA iOS" -sdk iphoneos -archivePath "archives/ios_devices.xcarchive" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO
xcodebuild archive -workspace "DeltaDNA.xcworkspace" -scheme "DeltaDNA iOS" -sdk iphonesimulator -archivePath "archives/ios_simulators.xcarchive" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO

# Bundle them together for users of Xcode 11 or greater
xcodebuild -create-xcframework -framework archives/ios_devices.xcarchive/Products/Library/Frameworks/DeltaDNA.framework -framework archives/ios_simulators.xcarchive/Products/Library/Frameworks/DeltaDNA.framework -output build/Frameworks/DeltaDNA.xcframework

# Compress the archive ready for distribution to GitHub
rm build/*.zip
zip -r DeltaDNA-4.13.2.zip build
mv DeltaDNA-4.13.2.zip build/
