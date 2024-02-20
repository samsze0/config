#!/usr/bin/env bash

# Generate a certificate
# Take 1 argument: expirationDays
openssl_create_certificate() {
	expirationDays="$1"

	openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days "$expirationDays"
}

# Generate the SHA checksum of a file using the 256 algorithm
shasum_256() {
	file="$1"
	shasum -a 256 "$file"
}
