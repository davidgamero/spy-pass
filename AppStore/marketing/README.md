# Spy Pass Marketing Assets

## App Store screenshots

- `app-store-iphone-6.3/`: 1206 × 2622, required iPhone slot
- `app-store-ipad-13/`: 2064 × 2752, required iPad slot

Each screenshot combines a short gameplay explanation with the real app interface. All files are RGB PNG images without alpha channels.

## Promotional graphics

- `spy-pass-header-2400x1200.png`: wide website, press, and social header
- `spy-pass-social-1200x1200.png`: square social post
- `app-store-product-header-3840x1646.png`: App Store product-page header at 21:9
- `app-store-search-2400x1600.png`: App Store search-results creative at 3:2

## Regenerate

Run:

```sh
python3 AppStore/marketing/generate_marketing_assets.py
```

The generator reads the raw screenshots under `AppStore/screenshots/` and the app icon from the asset catalog.

Upload and place the App Store creative assets with:

```sh
fastlane ios upload_creative_assets
```
