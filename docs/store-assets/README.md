# ExamTree store assets

`examtree-play-icon-512.png` is the canonical Google Play listing icon generated from the same shipping ExamTree brand treatment used by the mobile authentication header:

- mark: rounded account-tree glyph;
- foreground: white;
- brand background: `#4F46E5`;
- canvas: 512 × 512 PNG.

Android launcher resources use the same mark and brand color. Android 8+ receives adaptive foreground/background layers, with a monochrome layer for themed icons. Pre-Android-8 launchers use the density-specific `mipmap-*/ic_launcher.png` resources.

Do not replace these files with Flutter template launcher artwork. `test/launcher_assets_test.dart` protects the expected dimensions, adaptive layers, brand token, store asset and notification-icon wiring.
