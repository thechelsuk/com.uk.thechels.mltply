#!/bin/zsh
# App Store screenshots: runs the app in demo mode on a 6.3" iPhone and a 13" iPad simulator, captures each screen,
# then frames them.
#
#   tools/screenshots.sh              capture and frame
#   tools/screenshots.sh --frame      frame existing captures in screenshots/raw
#
# Output: screenshots/raw and screenshots/raw/ipad (plain captures) and screenshots/appstore/<size> (see tools/frame.py).
set -e
cd "${0:A:h}/.."
DEVICE=${DEVICE:-"iPhone 18 Pro"}
IPAD=${IPAD:-"iPad Pro 13-inch"}
RAW=screenshots/raw
DD=build/screens
mkdir -p $RAW/ipad screenshots/appstore

# name, then the launch arguments after -demo (see Mltply/Helpers/Demo.swift)
SCREENS=(
  "chat|"
  "timed|-timed"
  "settings|-screen settings"
  "scoreboard|-screen scoreboard"
  "achievements|-screen achievements"
)

capture() {   # capture <simulator name> <output folder>
  local device=$1 out=$2
  local udid=$(xcrun simctl list devices available | grep "$device (" | head -1 | grep -oE '[0-9A-F-]{36}')
  xcrun simctl boot $udid 2>/dev/null || true
  xcrun simctl bootstatus $udid -b >/dev/null
  xcrun simctl ui $udid appearance light
  xcrun simctl status_bar $udid override --time 9:41 --dataNetwork wifi --wifiBars 3 --cellularBars 4 --batteryState charged --batteryLevel 100
  for entry in $SCREENS; do
    local name=${entry%%|*} args=(${=${entry#*|}})
    # a fresh install each time, so one screen's round doesn't carry into the next
    xcrun simctl uninstall $udid TheChelsUK.Mltply 2>/dev/null || true
    xcrun simctl install $udid $DD/Build/Products/Debug-iphonesimulator/Mltply.app
    xcrun simctl launch $udid TheChelsUK.Mltply -demo $args >/dev/null
    sleep 9
    xcrun simctl io $udid screenshot --type png $out/$name.png >/dev/null 2>&1
    echo "captured $device $name"
  done
  xcrun simctl terminate $udid TheChelsUK.Mltply 2>/dev/null || true
  xcrun simctl status_bar $udid clear
  xcrun simctl shutdown $udid
}

if [[ "$1" != "--frame" ]]; then
  xcodebuild -project Mltply.xcodeproj -scheme Mltply -destination "generic/platform=iOS Simulator" -derivedDataPath $DD build -quiet
  capture "$DEVICE" $RAW
  capture "$IPAD" $RAW/ipad
fi

python3 tools/frame.py
