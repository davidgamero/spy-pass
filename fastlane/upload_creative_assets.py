#!/usr/bin/env python3

import base64
import json
import os
import sys
import time
from pathlib import Path

import requests
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature


REPOSITORY = Path(__file__).resolve().parents[1]
ENV_FILE = Path(__file__).resolve().parent / ".env"
API_ROOT = "https://api.appstoreconnect.apple.com"
BUNDLE_ID = "com.david340805.SpyPass"
VERSION = "1.0"
LOCALE = "en-US"

ASSETS = [
    {
        "path": REPOSITORY / "AppStore/marketing/app-store-product-header-3840x1646.png",
        "name": "Spy Pass Product Page Header",
        "placement": "PRODUCT_PAGE_HEADER_ASSET",
    },
    {
        "path": REPOSITORY / "AppStore/marketing/app-store-search-2400x1600.png",
        "name": "Spy Pass Search Results",
        "placement": "APP_STORE_SEARCH_RESULTS_ASSET",
    },
]


def load_environment() -> None:
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            name, value = line.split("=", 1)
            os.environ.setdefault(name, value)


def base64_url(data: bytes) -> bytes:
    return base64.urlsafe_b64encode(data).rstrip(b"=")


def create_token() -> str:
    key_id = os.environ.get("ASC_KEY_ID")
    issuer_id = os.environ.get("ASC_ISSUER_ID")
    key_path = os.environ.get("ASC_KEY_FILEPATH")
    if not all((key_id, issuer_id, key_path)):
        raise RuntimeError("Missing ASC_KEY_ID, ASC_ISSUER_ID, or ASC_KEY_FILEPATH")

    private_key = serialization.load_pem_private_key(
        Path(key_path).expanduser().read_bytes(),
        password=None,
    )
    now = int(time.time())
    header = base64_url(
        json.dumps(
            {"alg": "ES256", "kid": key_id, "typ": "JWT"},
            separators=(",", ":"),
        ).encode()
    )
    payload = base64_url(
        json.dumps(
            {
                "iss": issuer_id,
                "iat": now,
                "exp": now + 1200,
                "aud": "appstoreconnect-v1",
            },
            separators=(",", ":"),
        ).encode()
    )
    encoded = header + b"." + payload
    signature = private_key.sign(encoded, ec.ECDSA(hashes.SHA256()))
    r, s = decode_dss_signature(signature)
    raw_signature = r.to_bytes(32, "big") + s.to_bytes(32, "big")
    return (encoded + b"." + base64_url(raw_signature)).decode()


class AppStoreConnect:
    def __init__(self) -> None:
        self.session = requests.Session()
        self.session.headers.update(
            {
                "Authorization": f"Bearer {create_token()}",
                "Content-Type": "application/json",
            }
        )

    def request(self, method: str, path: str, **kwargs) -> dict:
        response = self.session.request(
            method,
            API_ROOT + path,
            timeout=90,
            **kwargs,
        )
        if not response.ok:
            raise RuntimeError(
                f"App Store Connect {method} {path} failed ({response.status_code}): "
                f"{response.text[:2000]}"
            )
        if not response.content:
            return {}
        return response.json()


def first_id(response: dict, label: str) -> str:
    data = response.get("data", [])
    if not data:
        raise RuntimeError(f"Could not find {label}")
    return data[0]["id"]


def find_resources(api: AppStoreConnect) -> tuple[str, str, str]:
    app_id = first_id(
        api.request("GET", "/v1/apps", params={"filter[bundleId]": BUNDLE_ID}),
        "app",
    )
    library_id = api.request("GET", f"/v1/apps/{app_id}/assetLibrary")["data"]["id"]
    version_id = first_id(
        api.request(
            "GET",
            f"/v1/apps/{app_id}/appStoreVersions",
            params={"filter[platform]": "IOS", "filter[versionString]": VERSION},
        ),
        "editable app version",
    )
    localizations = api.request(
        "GET",
        f"/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations",
    )["data"]
    localization = next(
        (item for item in localizations if item["attributes"].get("locale") == LOCALE),
        None,
    )
    if localization is None:
        raise RuntimeError(f"Could not find {LOCALE} localization")
    return app_id, library_id, localization["id"]


def remove_existing_placement(
    api: AppStoreConnect,
    localization_id: str,
    placement_type: str,
) -> None:
    placements = api.request(
        "GET",
        f"/v1/appStoreVersionLocalizations/{localization_id}/placements",
        params={"filter[placementType]": placement_type, "limit": 20},
    ).get("data", [])
    for placement in placements:
        print(f"Removing existing {placement_type} placement {placement['id']}")
        api.request("DELETE", f"/v1/appAssetLibraryPlacements/{placement['id']}")


def upload_asset(
    api: AppStoreConnect,
    library_id: str,
    file_path: Path,
    reference_name: str,
) -> str:
    file_bytes = file_path.read_bytes()
    reservation = api.request(
        "POST",
        "/v1/appAssetLibraryImages",
        json={
            "data": {
                "type": "appAssetLibraryImages",
                "attributes": {
                    "fileName": file_path.name,
                    "fileSize": len(file_bytes),
                    "category": "CREATIVE_ASSETS",
                    "referenceName": reference_name,
                },
                "relationships": {
                    "assetLibrary": {
                        "data": {"type": "appAssetLibraries", "id": library_id}
                    }
                },
            }
        },
    )
    asset = reservation["data"]
    asset_id = asset["id"]
    operations = asset["attributes"].get("uploadOperations", [])
    if not operations:
        raise RuntimeError(f"No upload operations returned for {file_path.name}")

    for operation in operations:
        offset = operation["offset"]
        length = operation["length"]
        headers = {
            item["name"]: item["value"]
            for item in operation.get("requestHeaders", [])
        }
        response = requests.request(
            operation["method"],
            operation["url"],
            headers=headers,
            data=file_bytes[offset : offset + length],
            timeout=120,
        )
        response.raise_for_status()

    api.request(
        "PATCH",
        f"/v1/appAssetLibraryImages/{asset_id}",
        json={
            "data": {
                "type": "appAssetLibraryImages",
                "id": asset_id,
                "attributes": {"uploaded": True},
            }
        },
    )
    print(f"Uploaded {file_path.name} as asset {asset_id}")
    return asset_id


def find_existing_asset(
    api: AppStoreConnect,
    library_id: str,
    reference_name: str,
) -> str | None:
    assets = api.request(
        "GET",
        f"/v1/appAssetLibraries/{library_id}/images",
        params={
            "filter[category]": "CREATIVE_ASSETS",
            "filter[referenceName]": reference_name,
            "sort": "-createdDate",
            "limit": 10,
        },
    ).get("data", [])
    for asset in assets:
        state = asset["attributes"].get("state")
        if state not in {"FAILED", "ARCHIVED", "AWAITING_UPLOAD"}:
            print(f"Reusing existing {reference_name} asset {asset['id']} ({state})")
            return asset["id"]
    return None


def wait_for_asset(api: AppStoreConnect, asset_id: str) -> None:
    for _ in range(60):
        asset = api.request("GET", f"/v1/appAssetLibraryImages/{asset_id}")["data"]
        state = asset["attributes"].get("state")
        if state in {
            "PREPARE_FOR_SUBMISSION",
            "READY_FOR_REVIEW",
            "WAITING_FOR_REVIEW",
            "IN_REVIEW",
            "ACCEPTED",
            "APPROVED",
        }:
            print(f"Asset {asset_id} processed: {state}")
            return
        if state == "FAILED":
            details = asset["attributes"].get("stateDetails")
            raise RuntimeError(f"Asset {asset_id} failed processing: {details}")
        time.sleep(2)
    raise RuntimeError(f"Timed out waiting for asset {asset_id}")


def place_asset(
    api: AppStoreConnect,
    asset_id: str,
    localization_id: str,
    placement_type: str,
) -> None:
    placement = api.request(
        "POST",
        "/v1/appAssetLibraryPlacements",
        json={
            "data": {
                "type": "appAssetLibraryPlacements",
                "attributes": {
                    "placementType": placement_type,
                    "placementGroup": "DEFAULT_PROFILE",
                },
                "relationships": {
                    "image": {
                        "data": {"type": "appAssetLibraryImages", "id": asset_id}
                    },
                    "appStoreVersionLocalization": {
                        "data": {
                            "type": "appStoreVersionLocalizations",
                            "id": localization_id,
                        }
                    },
                },
            }
        },
    )
    print(f"Created {placement_type} placement {placement['data']['id']}")


def main() -> None:
    load_environment()
    for asset in ASSETS:
        if not asset["path"].exists():
            raise RuntimeError(f"Missing creative asset: {asset['path']}")

    api = AppStoreConnect()
    _, library_id, localization_id = find_resources(api)
    print(f"Using asset library {library_id} and {LOCALE} localization {localization_id}")

    deferred: list[str] = []
    for asset in ASSETS:
        remove_existing_placement(api, localization_id, asset["placement"])
        asset_id = find_existing_asset(api, library_id, asset["name"])
        if asset_id is None:
            asset_id = upload_asset(api, library_id, asset["path"], asset["name"])
        wait_for_asset(api, asset_id)
        try:
            place_asset(api, asset_id, localization_id, asset["placement"])
        except RuntimeError as error:
            if "STATE_ERROR.INVALID_STATE" not in str(error):
                raise
            deferred.append(asset["placement"])
            print(
                f"Deferred {asset['placement']} placement because version {VERSION} "
                "is locked for review"
            )

    if deferred:
        print("Creative assets uploaded to Asset Library; placement deferred: " + ", ".join(deferred))
    else:
        print("Creative assets uploaded and placed successfully")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"error: {error}", file=sys.stderr)
        raise
