# Mltply

Mltply is a conversational math quiz app for kids, featuring a chat-style interface, bot questions, timer, difficulty selection, haptic feedback, and sound effects. Built with SwiftUI for iOS.

## Features

- Conversational chat interface with bot and user messages
- Math questions (addition, subtraction, multiplication, division)
- Timer and difficulty selection in chat
- Haptic feedback and sound effects
- Modern, iMessage-like UI

## Getting Started

1. Clone the repo
2. Open `Mltply.xcodeproj` in Xcode
3. Build and run on iOS 14+

## App Store screenshots

Run `tools/screenshots.sh` to produce them. It builds the app, runs it in demo mode on a 6.3" iPhone and a 13" iPad
simulator, captures five screens, then frames them in the colours of the app icon (`tools/frame.py`). Use
`tools/screenshots.sh --frame` to reframe existing captures after changing a caption. `tools/cpp.py` makes the custom
product pages from the same captures (see [custom-product-pages.md](custom-product-pages.md)).

Demo mode is the `-demo` launch argument, in debug builds only (see `Mltply/Helpers/Demo.swift`): Buddy plays a short
round by itself through the quiz's real logic, with one answer wrong. `-screen settings|scoreboard|achievements`
then opens that sheet, and `-timed` plays against the timer. The script installs the app fresh for every screen.

| Folder | Size | Display |
|---|---|---|
| `screenshots/raw`, `screenshots/raw/ipad` | 1206 × 2622, 2064 × 2752 | Plain captures |
| `screenshots/appstore/6.9`, `6.5`, `6.3` | 1320 × 2868, 1242 × 2688, 1206 × 2622 | iPhone |
| `screenshots/appstore/ipad-13`, `ipad-12.9` | 2064 × 2752, 2048 × 2732 | iPad |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT — see [LICENSE.md](LICENSE.md)
