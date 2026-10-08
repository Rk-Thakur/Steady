# Steady: Store Listing Text

Drafts for App Store Connect and Google Play Console. Character limits are noted next to each field; the counts in brackets are for the text as written.

> Check the name first: search "Steady" in both stores. If it's taken or too crowded, fall back to a longer name such as **"Steady: Daily Spending"** (22).

---

## Shared

**App name** (Apple 30 / Google 30)
```
Steady: Safe to Spend Today
```
[27]

**Category:** Finance
**Price:** Free (adjust if you charge)
**Age rating:** 4+ (Apple) / Everyone (Google)
**Support URL:** [your support page]
**Privacy policy URL:** [where you host docs/privacy-policy.md]

---

## Apple App Store

**Subtitle** (30)
```
One number. No spreadsheets.
```
[28]

**Promotional text** (170, can be changed without a new release)
```
Know what's safe to spend today, with bills, goals and payday already counted. Private by design: no account, no bank login, nothing leaves your phone.
```
[151]

**Keywords** (100, comma-separated, no spaces after commas)
```
budget,daily,spending,money,bills,payday,savings,goals,expense,tracker,allowance,split,freelance
```
[96]

**Description** (4000)
```
How much can I spend today?

Steady answers that with one number. It takes the money you have, sets aside the bills due before payday and what you're saving for your goals, and spreads the rest over the days until you're paid. That's your number for today.

Spend less today, and tomorrow's number goes up. Spend more, and it's spread gently over the days ahead. No categories to balance, no spreadsheets, no guilt.

ONE NUMBER, ALWAYS UP TO DATE
• Safe to spend today, recalculated after every spend
• Tap it to see exactly how it's worked out, and why it changed since yesterday
• "Can I afford it?" before you buy

BILLS, HANDLED
• Bills due before payday are set aside automatically
• A heads-up for big bills right after payday, like rent
• Estimates for bills that change, like electric
• Reminders before bills are due

GOALS THAT FILL THEMSELVES
• Emergency fund, a trip, a new laptop: pick a target and a pace
• A little comes out of your number each day and moves into the goal on payday
• Pause any time and your number goes back up

UNEVEN INCOME? PAYCHECK VAULT
• For freelance, gig and commission pay
• Big weeks fill the Vault; every Monday it pays you a steady amount
• Slow weeks are covered, so your number doesn't swing

SPLIT EXPENSES
• Share costs with a partner, flatmates or a trip group
• Simplified debts: the fewest payments to settle everyone
• Gentle reminders to collect what you're owed

UNDERSTAND YOUR HABITS
• Tag a mood when you spend and see what drives your spending
• Weekly and monthly summaries, plus a PDF report
• Late-night spending and planned vs unplanned

PRIVATE BY DESIGN
• No account, no sign-up, no bank login
• Everything stays on your phone, in an encrypted database
• App lock with a PIN and Face ID
• Encrypted backup files you control
• No ads, no tracking, no analytics

Steady is manual by design: logging a spend takes a few seconds, and doing it is what keeps you aware of your money.
```

**What's New** (version 1.0)
```
Welcome to Steady. Your first daily number is a minute away.
```

---

## Google Play

**Short description** (80)
```
Know what's safe to spend today. Bills and goals counted. Private, no account.
```
[78]

**Full description** (4000): use the Apple description above. Google allows the same text; keep the bullet characters.

**Tags** (pick up to 5 in Play Console): Budget, Personal finance, Expense tracker, Money manager, Savings

---

## Screenshot captions (one per screenshot)

Short, large text over each screenshot. Suggested order:

1. **Your safe-to-spend number for today.** (Today screen)
2. **See exactly how it's worked out.** (breakdown sheet with "Since yesterday")
3. **Bills set aside before payday.** (Bills radar)
4. **Goals that fill themselves.** (Goals list with "set aside this cycle")
5. **Uneven pay, steady weekly pay.** (Paycheck Vault)
6. **Split with friends. Settle in fewer payments.** (split group)
7. **Learn what drives your spending.** (Insights)
8. **Private. No account. Nothing leaves your phone.** (App lock / Face ID)

Required sizes:
- **Apple:** 6.9" iPhone (1320 × 2868) is required; iPad only if you ship for iPad.
- **Google:** at least 2 phone screenshots (1080 × 1920 or larger), plus a 1024 × 500 feature graphic.

Use **Load sample data** (Settings, debug builds only) to fill the screens with realistic numbers, then capture from the same debug build: the debug banner is already hidden in Steady.
