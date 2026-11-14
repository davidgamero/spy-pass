# App Store Screenshots

The screenshot folders contain raw captures from the shipping SwiftUI interface. The five states are:

1. Setup with public names
2. Hidden player card
3. Revealed secret name
4. Spy role
5. Discussion with names in play

Screenshot state seeding is compiled only in Debug builds. Launch a Debug build with:

```text
--screenshot-state setup
--screenshot-state hidden
--screenshot-state secret
--screenshot-state spy
--screenshot-state discussion
```

Capture one simulator at a time. Shut down the current simulator before booting a different device.

Compact front-screen audit captures and findings are stored in `../ui-audit/iphone-duo-front/`.
