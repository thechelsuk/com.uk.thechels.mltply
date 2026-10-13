# Mltply: custom product pages

App Store Connect › Growth & Marketing › Custom Product Pages. Each page leads with one reason to download, for one
kind of parent; the default page (Description.md) stays the broad pitch. Artwork comes from `tools/cpp.py`, into
`screenshots/cpp/<page>/`, made from the captures `tools/screenshots.sh` takes in demo mode. Keep British spelling,
and keep it suitable for children: no claims about results or school outcomes.

| Field | File or limit |
|---|---|
| Header | `header-5244x2950.png` (laid out for iPhone's crop) or `header-3840x1646.png` (Apple's header template safe area) |
| Search results | Leave empty: search then shows the page's first screenshots, which suits a portrait app better |
| iPhone 6.1" or 6.3" screenshots | `iphone-6.3-01…04-….png` (1206 × 2622), in order |
| iPad 13" screenshots | `ipad-13-01…04-….png` (2064 × 2752), in order |
| Second iPhone size (2034 × 1398 or 2853 × 2007) | Leave empty if optional: there's no simulator for that display to capture from |
| Deep link | Leave blank: the app has no links to a screen |
| Promotional text | 170 characters at most |
| Keywords | 100 characters at most, commas, no spaces; give each page its own, not the default page's |

## Default page

The main product page takes a header too: `screenshots/cpp/default/` (the chat). Leave its search results empty, as
on the custom pages. Its default screenshots are rebuilt too, in `screenshots/appstore/` (6.9", 6.5", 6.3", and 13"
and 12.9" iPad); its text and keywords stay as they are in Description.md.

## Times tables

For parents looking for times tables practice, including for the Year 4 multiplication check.

- **Page name:** Times tables
- **Header and screenshots:** `screenshots/cpp/times-tables/` (the chat)
- **Promotional text:** Times tables practice that feels like texting a friend. Buddy asks, your child answers, and every right answer gets a cheer. No ads, no sign-up and nothing to buy.
- **Keywords:** times,tables,timestable,multiplication,multiply,mtc,check,year,4,practice,quiz,drill,kids,learn
- **Screenshots:** the chat, choosing the tables, achievements, the scoreboard

## Daily practice

For parents and home educators who want a few minutes of calm, distraction-free maths each day.

- **Page name:** Daily practice
- **Header and screenshots:** `screenshots/cpp/practice/` (settings)
- **Promotional text:** Adding, taking away, times tables and dividing in a calm chat with a friendly robot. Pick the numbers and the pace. No ads, no sign-up and nothing to buy.
- **Keywords:** maths,math,arithmetic,addition,subtraction,division,homeschool,ks1,ks2,primary,daily,mental,sums
- **Screenshots:** settings, the chat, the scoreboard, achievements

## Beat the clock

For confident children who want a challenge: speed, streaks and harder numbers.

- **Page name:** Beat the clock
- **Header and screenshots:** `screenshots/cpp/challenge/` (the timer)
- **Promotional text:** Two minutes on the clock: how many can they answer? Chase a personal best, keep the streak going, and work up from Starter to GOAT, with numbers up to 9,999.
- **Keywords:** speed,timer,challenge,race,fast,quick,fire,streak,brain,game,mental,maths,best,score,level
- **Screenshots:** the timer, the scoreboard, achievements, the levels
