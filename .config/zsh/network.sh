#!/usr/bin/env bash

# Find out the public-facing IP on this machine
my_ip() {
	curl ifconfig.me
}
