# ReadX iOS — design brief

Paste this into a design tool or agent. It is written for someone who has not
seen the project.

---

## The product

ReadX is a reading-habit app for Kazakhstan. People track daily reading habits,
post about what they read, earn points for streaks, and compete on a monthly
leaderboard that feeds a merch lottery. Audience is students and young
professionals, 16–30, mostly on iPhone. Copy is a mix of English labels and
Russian body text.

It already ships as a web app; this is the native iOS client, built in Flutter.

## What exists now

Dark-only theme, no light mode. Current tokens:

| Role | Hex |
| --- | --- |
| Background | `#15171C` |
| Card surface | `#1D2026` → `#22252C` (subtle gradient) |
| Raised surface | `#2A2E37` |
| Hairline border | `#282C34` |
| Brighter border | `#3A3F4A` |
| Accent | `#0077FF`, bright variant `#3D9BFF` |
| Accent gradient | `#0077FF` → `#00D4FF` |
| Streak gradient | `#FF9F0A` → `#FF6A3D` |
| Success / danger | `#30D158` / `#FF453A` |
| Text | `#FFFFFF` → `#C7CAD1` → `#8E93A0` → `#6C7280` |

Type: SF Pro. Counters 26–46pt at weight 800 with tight negative tracking and
tabular figures. Headings 18–22pt/700. Body 15pt/1.45. Captions 13pt. Labels
11pt.

Radii: 26 hero, 20 card, 17 nav item, 14 field, pill for chips.

Content column is capped at 420pt and centred. Side padding 18.

## The six screens

1. **Feed** — header with wordmark, three tabs (For You / Following / Liked),
   a list of post cards: avatar, username, relative time, text, optional image,
   like and comment counts.
2. **Habits** — a hero card on top showing monthly points and day streak with a
   progress bar, then a list of habit rows each with a check control and a
   streak count. Swipe left deletes.
3. **Points** — monthly and all-time leaderboards, medal treatment for the top
   three, the viewer's own rank pinned.
4. **Profile** — avatar with a gradient ring, name, follower counts, a 2×3 grid
   of stat cards (total points, streak, monthly points, rank, posts, habits),
   then tabs for the user's posts, likes and comments.
5. **Auth** — log in, register, password recovery. Wordmark, two fields, one
   primary button.
6. **Settings** — grouped rows, plus destructive actions (delete account,
   blocked users).

## What to fix

**The app reads as flat grey.** Every surface is the same value, so nothing
leads the eye. The empty states — which is all a new user sees — are especially
bare.

Specifically:

1. **Depth without noise.** Find a way to separate background, card and raised
   surface that survives a dark theme. Right now the three values are too close
   and the whole screen reads as one plane.

2. **An edge-to-centre gradient.** The client wants the light to come from the
   edges of the screen and fall towards the centre, with soft rounded falloff —
   rather than the current corner glows. Show how that behaves on a tall scroll
   view without banding on OLED.

3. **Give the profile stat grid a hierarchy.** Six identical boxes is the wrong
   answer. Two of the six matter most (total points, current streak); the rest
   are secondary.

4. **Make the empty states worth looking at.** Feed, habits and notifications
   all need an illustration or composition that says what the screen is for.
   Books, sparkles and streak flames are on-brand. Must be drawable in code.

5. **Motion.** Tab switches should fade or scale, never slide — the four tabs
   are siblings, not a history stack. Suggest a signature micro-interaction for
   completing a habit and for earning points.

## Hard constraints

- **Flutter, iOS only.** No CSS, no Lottie, no raster assets. Everything must be
  expressible as Flutter widgets: gradients, shadows, `CustomPainter`, implicit
  animations. Keep the bundle small.
- **Dark only.** There is no light palette to design against.
- **The accent is `#0077FF`.** It is the brand colour and shared with the web
  app. Everything else is open.
- **Must work at 320pt wide** (iPhone SE) without overflow, and at 430pt.
- **Accessibility:** body text has to clear WCAG AA on whatever background it
  sits on, and nothing below 11pt.
- **App Store review is pending**, so nothing that looks like a system alert, a
  purchase flow, or Apple's own UI.

## What to deliver

Screens 1–4 in both their empty and full states, plus the tab bar and one habit
card in all three of its states (pending, done, at-limit). Hand back the tokens
you changed, not just pictures.
