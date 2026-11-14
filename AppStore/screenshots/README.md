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

Polished App Store and promotional artwork is stored in `../marketing/`.

## App Store Connect upload sets

- `iphone-6.3-required/`: required iPhone set, 1206 × 2622, RGB PNG without alpha
- `ipad-13/`: required iPad set, 2064 × 2752, RGB PNG without alpha
- `iphone-6.9-optional/`: optional large-display set; do not upload it into the required 6.3-inch slot
- `iphone-duo-outer-1.1/`: version 1.1 raw Duo outer-display captures, 1398 × 2034

Polished Duo sets are stored under `../marketing/app-store-iphone-duo-outer/` and `../marketing/app-store-iphone-duo-inner/`.
