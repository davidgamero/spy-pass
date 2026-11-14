# Spy Pass Roadmap

## Add iPhone Duo App Store screenshots

Priority: Required before April 2027 for submissions built with the iOS 27.1 SDK or later.

Apple accepts two iPhone Duo screenshot sizes:

- Outer display: 1398 × 2034 pixels
- Inner display: 2007 × 2853 pixels

Tasks:

- Upgrade Fastlane to version 2.241.1 or later for iPhone Duo screenshot support.
- Capture the five App Store marketing states on the Duo outer display.
- Capture the same five states on the Duo inner display.
- Verify folded, unfolded, and display-transition layouts with one simulator running at a time.
- Keep text, cards, and controls clear of each display's status area, mask, and home indicator.
- Export every image as an RGB PNG without an alpha channel.
- Extend `fastlane/Fastfile` to stage and upload the Duo screenshot sets.
- Upload through the App Store Connect API and confirm processing completes.
- Update `AppStore/screenshots/README.md` with the final paths and dimensions.

Acceptance criteria:

- App Store Connect accepts both screenshot sets without resizing or alpha-channel errors.
- The outer-display set explains the full game loop despite its shorter viewport.
- The inner-display set uses the larger canvas without stretching the phone layout.
- The required iPhone and iPad screenshot sets remain unchanged.

Source: [Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)

## Add a short, optional How to Play tutorial

Research summary:

- Spyfall explains the two opposing goals first: the informed group identifies the spy, while the spy listens and tries to infer the secret.
- The Chameleon teaches the clue tradeoff directly: an obvious clue gives away the answer, while a vague clue makes an informed player look suspicious.
- Undercover structures the round as private information, clues, discussion, and voting.
- Apple's onboarding guidance recommends teaching one action at a time, keeping tutorials optional, and making help easy to find later.

Recommended tutorial structure:

1. **Check your card privately.** Most players see the same name. One player sees SPY.
2. **Give one short clue.** Prove you know the name without saying it or making it too easy for the spy.
3. **Listen for suspicious clues.** The spy must blend in and work out the name from what everyone says.
4. **Discuss and vote.** The group chooses a suspected spy, then reveals the answer in the app.

Tasks:

- Add a visible `How to play` action on the setup screen.
- Present the tutorial as a native SwiftUI sheet with four short pages or interactive steps.
- Let people skip or dismiss it immediately.
- Show it once for first-time players, then keep it available from setup.
- Use one worked clue example that demonstrates “too obvious,” “too vague,” and “useful.”
- Explain both roles in direct language:
  - Name shown: identify the spy without revealing the name.
  - SPY shown: blend in and infer the name.
- State that discussion and voting happen in the group; the app does not collect votes.
- Decide and document the house rule for whether a caught spy gets one final guess.
- Add a contextual first-round tip near the discussion instructions instead of repeating the full tutorial.
- Support VoiceOver, Dynamic Type, Reduce Motion, and compact iPhone Duo layouts.
- Add UI tests for opening, paging, skipping, completing, and reopening the tutorial.

Acceptance criteria:

- A first-time group can explain both roles and start a round after reading for under one minute.
- Returning players can start immediately without dismissing onboarding again.
- Tutorial language matches the terms used in the live game: name, clue, player, spy, vote, and reveal.
- The tutorial does not claim that the app runs voting, scoring, or win detection.
- Every tutorial screen works at accessibility text sizes without clipped controls.

Research sources:

- [Apple Human Interface Guidelines: Onboarding](https://developer.apple.com/design/human-interface-guidelines/ios/app-architecture/onboarding)
- [Apple: Onboarding for Games](https://developer.apple.com/app-store/onboarding-for-games)
- [Spyfall rules](https://www.ultraboardgames.com/spyfall/game-rules.php)
- [The Chameleon rules](https://www.ultraboardgames.com/the-chameleon/game-rules.php)
- [Undercover game rules](https://www.yanstarstudio.com/undercover-how-to-play)
