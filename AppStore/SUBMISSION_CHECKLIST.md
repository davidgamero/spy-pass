# Spy Pass App Store Submission Checklist

## Prepared in this repository

- App name, subtitle, description, promotional text, keywords, release notes, and review notes
- App icon with standard, dark, and tinted appearances
- Screenshot capture states for setup, hidden card, secret card, spy card, and discussion
- Privacy disclosure draft stating that the app collects no data
- Public support and privacy pages under `docs/`
- Version 1.0, build 1

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

## Release blockers to resolve before archiving

- Lower the current iOS deployment target from 27.2 to the oldest iOS version the app will support
- Confirm whether the release should support both iPhone and iPad; iPad support requires its own screenshot set
- Set a final copyright string in the target settings
