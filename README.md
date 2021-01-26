# About this project
This is a sample project showing how to use Dart and Flutter to connect to Google services.  This particular project connects to Google Drive and creates a file.  Other services would have similar authentication and authorization requirements with differences in how the service is accessed.

# Setup
You will need to set up API access on the [Google Developer Console](https://console.developers.google.com/).

1. Create a new project from the "Select a project" dropdown.
1. Be sure project is selected in dropdown after it is created.
1. Select "Library" from the left menu.
1. Search for "Drive".  Select "Google Drive API" from the results.
1. Click the "Enable" button.
1. Click "OAuth consent screen" from the left menu.
    1. Choose "External" for User Type.
    1. Fill in the required fields (App Name, email addresses).
    1. This information will appear on the consent screen.
    1. Click "Save and Continue" at the bottom of the screen.
1. The next screen will have you choose Scopes.
    1. Click "Add or Remove Scopes" button.
    1. Filter for "drive.file". Select the checkbox for that scope.
    1. Click the "Update" button.
    1. Click "Save and Continue".
1. The next screen will have you add a test user.
    1.  This is for testing only.  Once (if?) you have "published" your app this is unnecessary.  Since this is a test app, this probably won't get published.
    1. Add the user you will use on your emulator.
1. Select "Credentials" from the left menu.
1. Click "Create Credentials" at the top of the page.
1. Choose the "OAuth client ID" option.
1. Choose Android.
1. Choose a name (or leave it the default).
1. Package name must match the package name in the `AndroidManifest.xml` file.  If you clone this repository, you will need to change it as the package currently set there has already been claimed.
1. To get the SHA-1 fingerprint, `cd` into the `android` directory and execute this Gradle task: `./gradlew signingReport`.  Copy and past the appropriate entry.
1. Click into your new credentials and copy the client id you just created.  It will look something like `123456789453-lkajhsdlf89ah8fh9as98dhfb.apps.googleusercontent.com`.
   
Now to setup the project: 
1. Paste your Client ID in the file `lib/domain/secret.dart`.  It also needs to go in the `AndroidManifest.xml` file in a sort of reversed notation.  If the above example was your client id, this is how it will look: `com.googleusercontent.apps.123456789453-lkajhsdlf89ah8fh9as98dhfb`.
1. At this point, you should be able to run the code in an Android emulator.

I was unable to test this in an iOS emulator, but in theory it should work if you setup a Client ID for iOS in the Google Developer Console.
    

