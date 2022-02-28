#!/bin/bash

# Exits on error
set -e

# Constants

ARCHIVE_BASE_PATH="XCFramework_Archives"

# Rewrite Package.swift so that it declaras dynamic libraries, since the approach does not work with static libraries
perl -i -p0e 's/type: .static,//g' Package.swift
perl -i -p0e 's/type: .dynamic,//g' Package.swift
perl -i -p0e 's/(library[^,]*,)/$1 type: .dynamic,/g' Package.swift

# Read the command line arguments target, zip-version, and output-path
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -target)
            TARGET_NAME=$2
            shift
            ;;
        -zip-version)
            ZIP_VERSION=$2
            shift
            ;;
        -output-path)
            OUTPUT_PATH=$2
            shift
            ;;
        *)
            TARGET_NAME=$1
            ;;
    esac
    shift
done

if [ -z "$OUTPUT_PATH" ]
then
      OUTPUT_PATH="."
fi

OUTPUT_FILE_NAME="${TARGET_NAME}-${ZIP_VERSION}"

# Archive the target for all platforms that we plan to support
for PLATFORM in "iOS" "iOS Simulator"; do

    case $PLATFORM in
    "iOS")
    RELEASE_FOLDER="Release-iphoneos"
    ;;
    "iOS Simulator")
    RELEASE_FOLDER="Release-iphonesimulator"
    ;;
    esac

    ARCHIVE_PATH=$ARCHIVE_BASE_PATH/$RELEASE_FOLDER 

    xcodebuild archive -workspace .swiftpm/xcode/package.xcworkspace -scheme $TARGET_NAME \
            -destination "generic/platform=$PLATFORM" \
            -archivePath $ARCHIVE_PATH \
            -derivedDataPath ".build" \
            SKIP_INSTALL=NO \
            BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    FRAMEWORK_PATH="$ARCHIVE_PATH.xcarchive/Products/usr/local/lib/$TARGET_NAME.framework"
    MODULES_PATH="$FRAMEWORK_PATH/Modules"
    mkdir -p $MODULES_PATH

    BUILD_PRODUCTS_PATH=".build/Build/Intermediates.noindex/ArchiveIntermediates/$TARGET_NAME/BuildProductsPath"
    RELEASE_PATH="$BUILD_PRODUCTS_PATH/$RELEASE_FOLDER"
    SWIFT_MODULE_PATH="$RELEASE_PATH/$TARGET_NAME.swiftmodule"
    RESOURCES_BUNDLE_PATH="$RELEASE_PATH/${TARGET_NAME}_${TARGET_NAME}.bundle"

    # Copy Swift modules
    if [ -d $SWIFT_MODULE_PATH ]
    then
        cp -r $SWIFT_MODULE_PATH $MODULES_PATH
    else
        # In case there are no modules, assume C/ObjC library and create module map
        echo "module $TARGET_NAME { export * }" > $MODULES_PATH/module.modulemap
        # TODO: Copy headers
    fi

    # Copy resources bundle, if exists
    if [ -e $RESOURCES_BUNDLE_PATH ]
    then
        cp -r $RESOURCES_BUNDLE_PATH $FRAMEWORK_PATH
    fi

done

# Create and save the XCFramework
xcodebuild -create-xcframework \
-framework $ARCHIVE_BASE_PATH/Release-iphoneos.xcarchive/Products/usr/local/lib/$TARGET_NAME.framework \
-framework $ARCHIVE_BASE_PATH/Release-iphonesimulator.xcarchive/Products/usr/local/lib/$TARGET_NAME.framework \
-output $OUTPUT_PATH/$OUTPUT_FILE_NAME.xcframework
echo "XCFramework created successuflly at the output path."


# Zip the XCFRamework
echo "Start zipping XCFramework file..."
cd $OUTPUT_PATH; zip -r $OUTPUT_FILE_NAME.zip $OUTPUT_FILE_NAME.xcframework
rm -r $OUTPUT_FILE_NAME.xcframework
cd -
echo "XCFramework file zipped successuflly at the output path."

# Compute and save the checksum
echo "Start computing the checksum for the zipped XCFramework..."
CHECKSUM=$(swift package compute-checksum $OUTPUT_PATH/$OUTPUT_FILE_NAME.zip)
echo -n CHECKSUM | shasum -a 256 > $OUTPUT_PATH/$OUTPUT_FILE_NAME.sha256
echo "Checksum saved successuflly at the output path."
