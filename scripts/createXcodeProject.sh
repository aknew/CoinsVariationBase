rm -rf XcodeBuild
mkdir XcodeBuild
cd XcodeBuild
~/Qt/5.15.0/ios/bin/qmake -spec macx-xcode ../src/CoinsBases.pro
/usr/libexec/PlistBuddy -c "add UIFileSharingEnabled bool YES" Info.plist
open CoinsBases.xcodeproj/
