# Spy Pass App Store Submission Checklist

## Prepared in this repository

- App name, subtitle, description, promotional text, keywords, release notes, and review notes
- App icon with standard, dark, and tinted appearances
- Screenshot capture states for setup, hidden card, secret card, spy card, and discussion
- Privacy disclosure draft stating that the app collects no data
- Public support and privacy pages under `docs/`
- Version 1.0, build 1
- iOS 17.0 minimum deployment target
- iPhone and iPad support
- Games category and 2026 copyright metadata

## App Store Connect details still needed

- Confirm that "Spy Pass" is available as the App Store name
- Choose the primary category: Games
- Choose a secondary category, if wanted: Family or Casual
- Confirm the GitHub Pages support URL in App Store Connect
- Confirm the GitHub Pages privacy URL in App Store Connect
- Complete the age-rating questionnaire; the expected result is 4+
- Select "No, this app does not collect data" in App Privacy
- Confirm that the app contains no ads
- Set pricing and availability
- Complete agreements, tax, and banking details in App Store Connect
- Create the App Store Connect app using bundle ID `com.david340805.SpyPass`
- Upload the archive, attach the prepared screenshots, and submit for review

## Release build

- Release archive created at `AppStore/build/SpyPass-1.0-1.xcarchive`
- Distribution-signed IPA exported to `AppStore/build/SpyPass-1.0-1.ipa`
- Upload the exported package through Xcode Organizer or Transporter

## Version 1.1 preparation

- Tutorial implemented and verified with unit and UI tests
- Version 1.1 build 2 exported to `AppStore/build/SpyPass-1.1-2.ipa`
- Build 2 uploaded successfully to App Store Connect and TestFlight for processing
- iPhone Duo outer marketing screenshots prepared at 1398 × 2034
- iPhone Duo inner marketing screenshots prepared at 2007 × 2853
- Product-page header and search creative uploaded to Asset Library
- Version 1.1 metadata, Duo screenshots, and creative placements must be uploaded after version 1.0 leaves review and version 1.1 becomes editable
- Run `fastlane ios prepare_1_1` after version 1.0 leaves review to create 1.1, attach build 2, upload all metadata and screenshots, and place the creative assets
