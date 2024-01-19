#!/usr/bin/env bash

# Download and install lemminx
lemminx_init() {
	curl "https://github.com/redhat-developer/vscode-xml/releases/download/0.26.1/lemminx-osx-x86_64.zip" -L -o "lemminx.zip"
	unzip lemminx.zip
	rm lemminx.zip

  mv lemminx-osx-x86_64 "$HOME/bin/lemminx"
}
