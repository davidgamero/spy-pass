# App Store Connect API Setup

## Create the key

1. Open App Store Connect.
2. Go to **Users and Access**.
3. Open **Integrations**, then **App Store Connect API**.
4. Create a Team Key named `Spy Pass Automation`.
5. Select the **App Manager** role.
6. Download the `.p8` file. Apple allows one download.
7. Copy the Key ID and Issuer ID shown on the page.

## Store the key locally

Create the private-key directory:

```sh
mkdir -p ~/.appstoreconnect/private_keys
```

Move the downloaded file there. Keep Apple's original filename, which normally looks like:

```text
~/.appstoreconnect/private_keys/AuthKey_ABC123DEFG.p8
```

Do not commit or share the private key.

## Configure Fastlane

Copy the example configuration:

```sh
cp fastlane/.env.example fastlane/.env
```

Replace the placeholders in `fastlane/.env` with the Key ID, Issuer ID, and full path to the `.p8` file. This file is ignored by Git.

## Upload assets

Run:

```sh
fastlane ios upload_store_assets
```

The lane uploads the English metadata, the required 6.3-inch iPhone screenshots, and the 13-inch iPad screenshots. It does not upload a binary or submit the app for review.
