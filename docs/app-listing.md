# Mltply: App Store listing

Everything App Store Connect (ASC) asks for, in one place, laid out as OPMLMan's. British spelling, no emoji, and
keep it suitable for children: no claims about results or school outcomes. `tools/app-store-art check-listing` checks
the lengths. "Check in ASC" marks anything this repo and the public App Store page don't show.

## 0. Before the next release

1. Fill the "check in ASC" gaps below from App Store Connect, so this file matches the live listing.
2. If the release changes the quiz, update the description (§2) and the screenshots (§6).
3. Release: push to `main` with `[Release]` in the commit message. The commit message becomes What's New.

## 1. App information

From the public App Store page (apps.apple.com/gb/app/id6747147316, read 2026-11-18) unless marked.

| Field | Value |
| --- | --- |
| Name (30) | Mltply: Math Quiz for Kids (26) |
| Subtitle (30) | Times Tables & Addition Game (28) |
| Home screen name | Mltply (`CFBundleDisplayName`) |
| Bundle ID | TheChelsUK.Mltply |
| SKU | Check in ASC |
| Primary category | Education |
| Secondary category | Games › Trivia (the store lists Education, Trivia and Games) |
| Primary language | Check in ASC (the store lists English) |
| Content rights | Check in ASC |
| Price | Free, with no in-app purchases |
| Availability | Check in ASC |
| Copyright | © thechelsuk |
| Support URL | Check in ASC |
| Marketing URL | https://thechels.uk/projects/mltply (the store's "Developer Website" link) |
| Privacy policy URL | https://thechels.uk/app/privacy |
| Licence agreement | Apple's standard EULA (linked from the description as Terms of Use) |
| Platforms | iPhone and iPad, iOS 18.6 or later |

## 2. Listing text

### Promotional text (170)

Check in ASC: it isn't in the repo or on the public page. Paste it here.

```text

```

### Keywords (100)

Check in ASC: keywords aren't public. Paste them here.

```text

```

### Description (4000)

Matches the live listing (2026-11-18).

```text
Maths practice that feels like a chat, not a chore.

Mltply turns times tables, addition, subtraction and division into a friendly back-and-forth with a bot — kids answer questions in a chat bubble, get instant feedback, and build speed and confidence one message at a time.

HOW IT WORKS
• Bot asks, your child answers — just like texting a friend
• Choose the operation: addition, subtraction, multiplication or division
• Pick a difficulty level that matches their pace
• Beat the clock with a built-in timer for extra practice
• Haptic feedback and sound effects make every right answer feel good

BUILT FOR FOCUS
No ads. No in-app purchases. No sign-up. No distractions — just a clean, iMessage-style interface designed to keep kids practising, not scrolling.

Great for daily practice, homeschooling, or brushing up before school starts.

PREFER PAPER?
Printable Mltply maths workbooks for Years 1–7 (times tables, division, fractions and more, all with answers) are available at shop.thechels.uk. Try the free sampler first.

Privacy Policy: https://thechels.uk/app/privacy
Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```

### What's New

The live version (202701.3):

```text
bug fixes and improvements
```

Later versions: the `[Release]` commit message becomes What's New.

## 3. App Privacy (the "nutrition label")

Live label: **Data Not Collected**.

| What happens | Counts as collection? |
| --- | --- |
| Scores and settings stay on the device | No |
| No purchases, analytics, advertising or accounts | No |

[`Mltply/PrivacyInfo.xcprivacy`](../Mltply/PrivacyInfo.xcprivacy) (added 2026-11-18) declares no collected data and UserDefaults for the app's own
settings (`CA92.1`).

## 4. Review information

| Field | Value |
| --- | --- |
| Sign-in required | Check in ASC (the app has no accounts) |
| Contact | Check in ASC |
| Notes for the reviewer | Check in ASC: none are kept in the repo |

## 5. In-app purchases

None. The app has no StoreKit code or configuration, and the description says "No in-app purchases".

## 6. Screenshots and media

Made by `tools/app-store-art capture`, which builds the app, runs it in demo mode (`-demo`, debug builds only: Buddy
plays a short round by itself, with one answer wrong) on an iPhone and a 13" iPad simulator, and frames the captures
in the icon's colours. `tools/app-store-art render` frames existing captures again and makes the product page art.
The look and captions are in [`tools/app-store-art.toml`](../tools/app-store-art.toml).
`tools/app-store-art capture duo duo-cover` takes the iPhone Duo's two screens in the same style (unfold it
and turn it to landscape first for `duo`).

| Where in ASC | Files | Size |
| --- | --- | --- |
| iPhone 6.3" (medium display) | [`screenshots/appstore/6.3/`](../screenshots/appstore/6.3/) (5) | 1206 × 2622 |
| iPad 13" | [`screenshots/appstore/ipad-13/`](../screenshots/appstore/ipad-13/) (5) | 2064 × 2752 |
| iPhone Duo, outer screen | [`screenshots/appstore/duo-cover/`](../screenshots/appstore/duo-cover/) (5) | 1398 × 2034 |
| iPhone Duo, inner screen (unfolded, landscape) | [`screenshots/appstore/duo/`](../screenshots/appstore/duo/) (5) | 2853 × 2007 |
| Product page screenshots, iPhone Duo | `duo/` and `duo-cover/` in [`challenge`](../screenshots/cpp/challenge/), [`practice`](../screenshots/cpp/practice/), [`times-tables`](../screenshots/cpp/times-tables/) | |
| Product page header | [`screenshots/cpp/default/`](../screenshots/cpp/default/) | §10 |

ASC only needs the largest size of each kind; it scales the rest. There's no 6.3" set: ASC rejected 1206 × 2622.

The order:

| # | Screen | Headline | Line under it |
| --- | --- | --- | --- |
| 1 | The chat | Maths, but it's a chat | Buddy asks, your child answers, one message at a time |
| 2 | The timer | Beat the clock | Two minutes on the timer, or keep going as long as you like |
| 3 | Settings | Pick the numbers | Times tables, adding, taking away and dividing, at their pace |
| 4 | Achievements | Earn achievements | Streaks and milestones that celebrate every right answer |
| 5 | Scoreboard | Watch them improve | Every round on the scoreboard, with a personal best to beat |

## 7. Age rating

Live rating: **4+**. The questionnaire answers: check in ASC.

## 8. Where everything goes in App Store Connect

ASC › **Apps** › **Mltply: Math Quiz for Kids**, the **App Store** tab:

| What | Where | Section |
| --- | --- | --- |
| Name, subtitle, category, content rights, age rating, privacy policy URL | Sidebar › **General** › **App Information** | §1, §7 |
| App Privacy answers | Sidebar › **General** › **App Privacy** | §3 |
| Accessibility labels | Sidebar › **General** › **Accessibility** | §9 |
| Price and territories | Sidebar › **Monetization** › **Pricing and Availability** | §1 |
| Promotional text, description, keywords, screenshots, URLs, review notes, build | Sidebar › **iOS App** › the version | §2, §4, §6 |
| Product page header, custom product pages | Sidebar › **Growth & Marketing** › **Custom Product Pages** | §10 |

## 9. Accessibility (Accessibility Nutrition Labels)

None declared yet (the store page, 2026-11-18). Not assessed: try each feature with the app's common tasks (pick
the numbers, answer a round, see the scoreboard) before ticking it.

## 10. Product pages

ASC › **Growth & Marketing** › **Custom Product Pages**. Each page leads with one reason to download, for one kind of
parent; the default page keeps the broad pitch (§2). Artwork comes from `tools/app-store-art render`, into
`screenshots/cpp/<page>/`, made from the demo mode captures.

| Field | File or limit |
| --- | --- |
| Header | `header-5244x2950.png` (laid out for iPhone's crop) or `header-3840x1646.png` (Apple's header template safe area) |
| Search results | Leave empty: search then shows the page's first screenshots, which suits a portrait app better |
| iPhone screenshots | `iphone-6.3/01…04-….png` (1206 × 2622), in order. ASC scales them for the other iPhones |
| iPad 13" screenshots | `ipad-13/01…04-….png` (2064 × 2752), in order |
| iPhone Duo screenshots | `duo/01…04-….png` (2853 × 2007, unfolded) and `duo-cover/01…04-….png` (1398 × 2034, outer screen), in order |
| Deep link | Leave blank: the app has no links to a screen |
| Promotional text | 170 characters at most |
| Keywords | 100 characters at most, commas, no spaces; give each page its own, not the default page's |

### Default

- **Header:** [`screenshots/cpp/default/`](../screenshots/cpp/default/) (the chat). Leave its search results empty,
  as on the custom pages. Its text, keywords and screenshots are the main ones (§2, §6).

### Times tables

For parents looking for times tables practice, including for the Year 4 multiplication check.

- **Page name:** Times tables
- **Promotional text:** Times tables practice that feels like texting a friend. Buddy asks, your child answers, and every right answer gets a cheer. No ads, no sign-up and nothing to buy.
- **Keywords:** `times,tables,timestable,multiplication,multiply,mtc,check,year,4,practice,quiz,drill,kids,learn`
- **Art:** [`screenshots/cpp/times-tables/`](../screenshots/cpp/times-tables/) (the chat), then the chat, choosing the tables, achievements, the scoreboard

### Daily practice

For parents and home educators who want a few minutes of calm, distraction-free maths each day.

- **Page name:** Daily practice
- **Promotional text:** Adding, taking away, times tables and dividing in a calm chat with a friendly robot. Pick the numbers and the pace. No ads, no sign-up and nothing to buy.
- **Keywords:** `maths,math,arithmetic,addition,subtraction,division,homeschool,ks1,ks2,primary,daily,mental,sums`
- **Art:** [`screenshots/cpp/practice/`](../screenshots/cpp/practice/) (settings), then settings, the chat, the scoreboard, achievements

### Beat the clock

For confident children who want a challenge: speed, streaks and harder numbers.

- **Page name:** Beat the clock
- **Promotional text:** Two minutes on the clock: how many can they answer? Chase a personal best, keep the streak going, and work up from Starter to GOAT, with numbers up to 9,999.
- **Keywords:** `speed,timer,challenge,race,fast,quick,fire,streak,brain,game,mental,maths,best,score,level`
- **Art:** [`screenshots/cpp/challenge/`](../screenshots/cpp/challenge/) (the timer), then the timer, the scoreboard, achievements, the levels
