#!/usr/bin/env bash

# Creates and listen on unix socket server w/ netcat
nc_socket_listen() {
  nc -lU "$@"
}

# Connect to unix socket server w/ netcat
nc_socket_connect() {
  nc -U "$@"
}

# List sockets with lsof -U
list_socket() {
  lsof -U
}
