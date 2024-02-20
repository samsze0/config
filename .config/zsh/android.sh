#!/usr/bin/env bash

# Generate a signature hash for an Android app
android_generate_app_signature() {
	keyName="$1"
	if ! key=$(keytool -exportcert -alias "$keyName" -keystore ~/.android/debug.keystore); then
		echo "Error: keytool_generate_signature: keytool command failed"
		return 1
	fi
	echo "$key" | openssl sha1 -binary | openssl base64
}
