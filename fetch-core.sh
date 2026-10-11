#!/usr/bin/env bash
# Fetches the Corded core this app is built against, checks that it carries
# the release signature, and puts each piece where the builds look for it.
#
#   ./fetch-core.sh [linux] [android] [windows]        (no words: linux and android)
#
# Which core: the release named in core.version, from AndrewCromar/corded.
# Needs curl, tar, unzip (for windows) and openssl.
set -euo pipefail
cd "$(dirname "$0")"
version="${CORDED_CORE_VERSION:-$(tr -d '[:space:]' < core.version)}"   # the variable is for trying another core by hand
base="https://github.com/AndrewCromar/corded/releases/download/${version}"
wanted="${*:-linux android}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fetch() {   # fetch <file name>: downloaded and its signature checked, or the script stops
  curl -fsSL --retry 3 -o "$tmp/$1" "$base/$1"
  curl -fsSL --retry 3 -o "$tmp/$1.sig" "$base/$1.sig"
  openssl pkeyutl -verify -rawin -pubin -inkey packaging/release-signing.pub -in "$tmp/$1" -sigfile "$tmp/$1.sig" >/dev/null \
    || { echo "$1 does not carry the release signature; not used" >&2; exit 1; }
}

for part in $wanted; do
  case "$part" in
    linux)
      name="corded-${version}-linux-x86_64"
      fetch "$name.tar.gz"
      mkdir -p core/linux
      tar -xzf "$tmp/$name.tar.gz" -C "$tmp"
      # The library for the app; the server and the headless client for the binding's test.
      cp "$tmp/$name/libcorded.so" "$tmp/$name/cordedd" "$tmp/$name/corded-cli" core/linux/
      ;;
    android)
      name="corded-core-${version}-android-arm64"
      fetch "$name.tar.gz"
      tar -xzf "$tmp/$name.tar.gz" -C "$tmp"
      mkdir -p app/android/app/src/main/jniLibs
      cp -r "$tmp/$name/jniLibs/." app/android/app/src/main/jniLibs/
      ;;
    windows)
      name="corded-${version}-windows-x64"
      curl -fsSL --retry 3 -o "$tmp/$name.zip" "$base/$name.zip"
      # The Windows archive of the server is published without a signature of
      # its own; its checksum is taken from the release page by whoever needs more.
      mkdir -p core/windows
      unzip -q -o "$tmp/$name.zip" -d "$tmp"
      cp "$tmp/$name/corded.dll" core/windows/
      ;;
    *) echo "unknown part: $part (linux, android or windows)" >&2; exit 2 ;;
  esac
  echo "core ${version}: ${part} in place"
done
