# Sihhatk iPhone App

Sihhatk has been converted into a native SwiftUI iPhone project. The app keeps the original flow: local sign in/register, onboarding questions, calorie target tracking, meal photo analysis, history logs, Arabic/English language switching, and light/dark mode.

## Open in Xcode

1. Open `Sihhatk.xcodeproj` in Xcode 15 or newer.
2. Select the `Sihhatk` scheme.
3. Choose an iPhone simulator or connected iPhone.
4. Press Run.

The deployment target is iOS 16.0.

## Create an IPA for Sideloadly

An IPA must be built on macOS with Xcode installed. From this folder on a Mac, run:

```sh
xcodebuild \
  -project Sihhatk.xcodeproj \
  -scheme Sihhatk \
  -configuration Release \
  -sdk iphoneos \
  -archivePath build/Sihhatk.xcarchive \
  archive CODE_SIGNING_ALLOWED=NO

rm -rf Payload Sihhatk.ipa
mkdir Payload
cp -R build/Sihhatk.xcarchive/Products/Applications/Sihhatk.app Payload/
zip -qry Sihhatk.ipa Payload
rm -rf Payload
```

Then open `Sihhatk.ipa` in Sideloadly. Sideloadly can apply signing with your Apple ID during installation.

## Gemini Setup

The app builds without an API key and uses a demo nutrition analysis response so you can test the UI immediately.

To enable real image analysis:

1. Open `Sihhatk/Info.plist`.
2. Set `GeminiAPIKey` to your Gemini API key.
3. Keep or change `GeminiModelName` if you want to use a different Gemini model.

For production, do not ship a private API key inside the app. Move the AI call behind your own backend and update `FoodAnalysisService.swift` to call that backend.

## Native Files

- `Sihhatk/SihhatkApp.swift` - app entry point.
- `Sihhatk/Views.swift` - SwiftUI authentication, onboarding, dashboard, history, profile, and results UI.
- `Sihhatk/AppStore.swift` - local app memory using `UserDefaults`.
- `Sihhatk/FoodAnalysisService.swift` - Gemini REST integration plus demo fallback.
- `Sihhatk/Models.swift` - user, profile, history, and nutrition models.
- `Sihhatk/Translations.swift` - English and Arabic app copy.
- `Sihhatk/ImagePicker.swift` - camera bridge for SwiftUI.

The project now contains only the native iPhone/Xcode app files plus this README.
