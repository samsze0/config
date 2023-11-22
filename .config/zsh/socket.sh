#!/usr/bin/env bash

# Creates and listen on unix socket server
nc_socket_listen() {
  nc -lU "$@"
}

# Connect to unix socket server
nc_socket_connect() {
  nc -U "$@"
}
