# The Corded app

The app for [Corded](https://github.com/AndrewCromar/corded), an end-to-end
encrypted chat you host yourself. One Flutter app for Android, Linux and
Windows, on top of the Corded core.

| Folder | What is in it |
|---|---|
| `app/` | The app |
| `packages/corded_dart/` | The Dart binding to the core that the app is built on; usable on its own |
| `packaging/` | What goes into the desktop archives beside the app, and the public half of the release key |
| `core.version` | Which release of the core this app is built against |

## Get it

Releases are on the [releases page](https://github.com/opencorded/app/releases):
`corded-android-arm64.apk`, `corded-app-…-linux-x86_64.tar.gz`,
`corded-app-…-windows-x64.zip`, each with a signature. An installed app
updates itself from there (Settings, Check for updates) and installs nothing
that does not carry the release signature.

## Build it

The core is not built here. It is fetched from its own release, and its
signature is checked before it is used:

```sh
./fetch-core.sh linux android      # or: windows
cd app
flutter pub get
flutter build linux --release      # or: apk, windows
```

`CORDED_CORE_LIB` (Linux) and `CORDED_CORE_DLL` (Windows) point the build at
a core you built yourself from the main repository instead.

To build against a newer core, change `core.version` to its release tag. A
change that needs something new from the core therefore takes two steps: the
core is released first, then this file moves to it.

## Tests

```sh
cd app && flutter analyze && flutter test
cd packages/corded_dart && CORDED_BIN=../../core/linux CORDED_LIB=../../core/linux/libcorded.so dart test
```

The second runs two clients through a real server, driven from Dart.

## Versions

The app has its own version numbers from 0.7.0 on. Before that it was built
in the main repository and shared its numbers; its history from there is kept
here.

Apache-2.0.
