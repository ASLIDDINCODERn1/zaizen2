# Zaizen lib structure

```
lib/
  main.dart
  core/                 shared building blocks
    l10n/               translations + locale
    theme/              colors, theme, status bar
    widgets/            reusable UI
    network/            connectivity screens
  features/
    splash/             launch animation
    auth/               login, session, profile store
      data/
      presentation/
    home/               home + leaderboard + inbox
    profile/            profile + personal info
    settings/           settings, language, security, lock
```
