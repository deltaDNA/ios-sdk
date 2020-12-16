# Release Process

**Internal Use Only, please remove from the repo before publishing to public GitHub**

1. Update the version number using the `update-version` script, providing the old and new versions, for example `update-version 1.0.0 1.0.1`
2. Update the `CHANGELOG.md` with all changes being added in this release
3. Merge these updates into `develop`
4. Merge the release into master, and tag with the released version
5. Run `pod repo add deltaDNA git@github.com:deltaDNA/CocoaPods.git` to add the deltaDNA Cocoapods repo
6. Run `pod lib lint --allow-warnings --verbose --use-libraries -- sources=https://github.com/deltaDNA/CocoaPods,https://github.com/CocoaPods/Specs` to ensure the Cocoapods setup is still valid
7. Push the podspec to the repo using `pod repo push deltaDNA --allow-warnings --verbose --use- libraries --sources=https://github.com/deltaDNA/CocoaPods,https://github.com/CocoaPods/Specs`
8. Remove the release process file and push to public GitHub