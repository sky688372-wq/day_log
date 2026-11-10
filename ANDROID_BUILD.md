# Hotspot test APK

This build fixes Android release networking by including `INTERNET` in the main
manifest and explicitly allowing HTTP for the configurable local demo backend.

The GitHub Actions workflow builds a release APK with
`API_SERVER_ADDRESS=http://192.168.137.1:8000`. The developer screen can still
override the address; a previously saved address takes precedence.

The PC backend must listen on `0.0.0.0:8000`, and the phone must be connected to
the PC hotspot. Verify `http://192.168.137.1:8000/health` in the phone browser.

The existing project signs release builds with a debug certificate. This CI build
uses a newly generated certificate, so installing over an APK built elsewhere may
fail. Uninstalling the old app clears local login/settings; server-side account
and study records remain. No app is uninstalled automatically.

The workflow checks the packaged APK for the INTERNET permission and publishes
the APK plus SHA-256 on a `hotspot-*` tag. The template counter widget test does
not describe this app's screens and is not used as a networking check.

For an externally hosted production backend, use HTTPS and revise the local HTTP
network policy accordingly. This APK is intended for the local hotspot demo.
