#!/usr/bin/env bash

# Find out the public-facing IP on this machine
my_ip() {
	curl ifconfig.me
}

# List the processes that are occupying the specified port
list_processes_using_port() {
  lsof -i :$1
}
