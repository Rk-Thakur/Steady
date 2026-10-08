# Steady 1.0: Release Checklist

Work top to bottom. Tick each box when it's done.

---

## 1. Blockers (must be done before any store submission)

- [ ] **Remove the Firebase SDK from the app** (added back in commit `d34adb6`, "Firebase Added for the QA Team").
  - App Distribution doesn't need the SDK: upload builds with the Firebase CLI (`firebase appdistribution:distribute`) or drag them into the console.
  - While `Firebase.initializeApp` runs in `lib/main.dart`, the app can contact Google's servers and gets the Android INTERNET permission. That contradicts `docs/privacy-policy.md` and the "Data not collected" store answers below.
  - To remove it:
    - `lib/main.dart`: the import and `Firebase.initializeApp`
    - `lib/firebase_options.dart`
    - `firebase_core` in `pubspec.yaml`
    - the `com.google.gms.google-services` lines in `android/app/build.gradle.kts` and `android/settings.gradle.kts`
    - the GoogleService entries in the Xcode project
  - Keep `firebase.json` if the CLI uses it.
  - **If you decide to keep Firebase**, update the privacy policy and both stores' privacy answers to match before release.
- [ ] **Register `app.dailynumber.steady` in Firebase App Distribution** (the old `com.example` app IDs in `firebase.json` won't accept the new builds).
- [ ] **Support email:** set `supportEmail` in `lib/app/support.dart`, and fill in `[SUPPORT EMAIL]` in the privacy policy.
- [ ] **Host the privacy policy** at a public URL (GitHub Pages, Notion, or a simple site). Fill in `[DATE]` and `[YOUR NAME]`.
- [ ] **iOS signing:** in Xcode › Runner › Signing & Capabilities, choose your team for `app.dailynumber.steady`; create the App ID and distribution certificate in the Apple Developer account.
- [ ] **Name check:** search "Steady" in both stores and a trademark database. See the fallback in `docs/store-listing.md`.
- [ ] **Commit** the current work, including:
  - `drift_schemas/steady/drift_schema_v10.json` and `drift_schema_v11.json`
  - `test/drift/steady/generated/schema_v10.dart` and `schema_v11.dart`

---

## 2. Device testing

Do these on the **iPhone simulator**, the **Android emulator**, and then **one real iPhone and one real Android phone**. Real phones matter most for Face ID and fingerprint, notifications, and the encrypted database.

### 2a. Upgrade with existing data (do this first)

- [ ] Install the **last committed build**, use it a bit (a few spends, a goal, a bill), then install the **new build over it** without deleting the app.
- [ ] The app opens without an error. Goals, bills, entries and settings are all still there.
- [ ] Goals list shows "+$X set aside this cycle · added on payday" (the database upgraded to v10 and gave each goal its share).
- [ ] Restore an **older backup file** (made before this round). Everything comes back.

### 2b. Stage by stage

- [ ] **1. Onboarding:** fresh install, then the money step shows the "Count only money you spend from…" hint; the bills step says "Only bills due before your next payday…".
- [ ] **2. Bill double-count:** Log spend, type a bill's name (e.g. "Rent"), and Save. "Is this your Rent bill?" appears. "Mark Rent as paid" marks the bill paid and leaves the daily number unchanged. "No, it's a normal spend" saves it as a spend.
- [ ] **3. Why $X:** the ⓘ next to "Safe to spend today" is visible. Log a spend for yesterday, and the hero shows "Down $X from yesterday: you spent more". Tapping the hero shows "Since yesterday", and the rows add up.
- [ ] **4. Goals:**
  - Start a $10/day goal and the daily number drops about $10 straight away.
  - Pause it and the number goes back up.
  - New goal with "Already saved" equal to the target: the Start button is disabled.
  - Goal detail shows "How it fills up" and no fake history.
- [ ] **5. Payday:** set the payday to today (Profile), log income, return to Today, and the "New pay cycle" sheet opens once. Lines add up; each goal shows what it received. The banner's "See what carried over" reopens it.
- [ ] **6. After payday:** add a monthly bill due the day after payday. Today's bills card shows the heads-up; Bills shows "Right after payday". The daily number is unchanged.
- [ ] **7. Vault:**
  - With no Vault, the tab shows "How the Vault works". "Set steady pay" suggests an amount and opens + / −.
  - With a Vault, Today shows "Vault $X · $Y joins your number Mon…". The ? button explains it. The chart shows real weeks.
- [ ] **8. Splits:** someone owes you, so Today shows "$X owed back to you…". A 3-person chain group shows "Simplified: 1 payment instead of 2" and How? shows both lists.
- [ ] **9. Catch-up:** don't log for 2+ days (change the phone's date forward, or just wait), and Today shows catch-up.
  - "Nothing" on every day shows "All caught up", Today returns to normal, and **after closing and reopening the app it stays caught up**.
  - "Not now, show my day" shows the estimate banner, and "Catch up" brings it back.
  - With a single missed day, the banner offers "I spent nothing".
- [ ] **10. Category limits:** Log spend in Food shows "Food: $X left of $420 this month". An amount near the limit shows "Getting close." Over the limit shows "This takes Food $X over…". Health (no limit) shows no line.
- [ ] **12. Small items:**
  - Insights with no moods shows "No moods yet…".
  - Turn a reminder on, then turn off Steady's notifications in the phone's Settings, and return to the app. Settings › Reminders shows **Blocked**. Turn them back on, return, and it clears.
  - On an overspent day, "Cover it from Fun instead" explains what it does before you tap.
  - With App lock off, its subtitle mentions Face ID / your fingerprint.

### 2c. Things that only real phones show

- [ ] Face ID (iPhone) and fingerprint (Android) unlock; cancelling stays on the PIN pad.
- [ ] A reminder actually arrives at its time with the app closed, and tapping it opens the right screen.
- [ ] Reminders still arrive after restarting the phone (Android).
- [ ] Large text (phone setting at the biggest size): Today, Log spend, Goals, Bills, Vault are readable with nothing cut off.
- [ ] Dark mode on every main screen.
- [ ] Leaving the app for over a minute with App lock on asks for the PIN.

---

## 3. Closed beta (2–3 weeks)

A budgeting app needs a full pay cycle to be tested properly.

- [ ] Android: Firebase App Distribution (after the ID is registered). iOS: TestFlight.
- [ ] 5–10 testers, ideally with different pay types: salary, weekly pay, freelance (Vault).
- [ ] Ask them to go through at least one payday and one catch-up.
- [ ] Collect: anything confusing, any wrong number, any crash (with steps).

---

## 4. Store forms

### Apple App Store Connect

- [ ] **App Privacy:** "Data Not Collected" (true only once the Firebase SDK is removed).
- [ ] **Encryption:** Steady encrypts its own data with standard algorithms (AES, Argon2id). Answer the export-compliance questions in App Store Connect. Apps that only use standard encryption to protect the user's own data usually qualify for the exemption, but read Apple's questions carefully and confirm. Then set `ITSAppUsesNonExemptEncryption` in `Info.plist` to match, so you aren't asked on every upload.
- [ ] **Age rating:** 4+ (no objectionable content; no unrestricted web access).
- [ ] **Review notes:** "No login required. To see the app with data, complete onboarding (about 1 minute)." Reviewers can't use debug builds, so there's no sample data for them.
- [ ] Screenshots, description and keywords from `docs/store-listing.md`.

### Google Play Console

- [ ] **Data safety:** no data collected, no data shared; data is encrypted (on device); users can delete their data (Settings › Backup & export › Delete all my data).
- [ ] **Content rating questionnaire:** a finance utility with no user interaction or sharing between users.
- [ ] **Target audience:** 18+ (or 13+); not designed for children.
- [ ] **App access:** no login required.
- [ ] Upload the **AAB** signed with the upload key; enrol in Play App Signing.
- [ ] Short and full description, screenshots and feature graphic from `docs/store-listing.md`.

---

## 5. Strongly recommended (decide after the beta)

- [ ] **Backups (Stage 11):** data is only on the phone, so a lost phone means lost data. At least a reminder to make a backup after the first week; ideally an iCloud / Google Drive option.
- [ ] **Crash reports, opt-in:** if you add one (Sentry, Crashlytics), make it off by default with a clear consent screen, and update the privacy policy first.

---

## 6. Release day

- [ ] Version in `pubspec.yaml` (`1.0.0+1`; bump the build number for every upload).
- [ ] `flutter analyze` clean and `flutter test` all passing.
- [ ] Release builds: `flutter build appbundle --release` (Android) and `flutter build ipa --release` (iOS).
- [ ] Tag the commit, e.g. `v1.0.0`.
- [ ] Keep a short changelog, especially of database versions (now **v11**), so future migrations stay easy.
