# Test APK versioning contract

Authenticated Android APK builds use an explicit build name and a monotonically increasing UTC-hour build number so Android recognizes newer phone-test builds as upgrades. The workflow also caches the generated debug keystore under a stable cache key, allowing subsequent GitHub Actions debug APKs to share a signing identity.

These debug APKs are for internal testing only. Production release signing must use a dedicated protected release keystore.
