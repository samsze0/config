#!/usr/bin/env bash

# Log startup time metrics to log.out
nvim_startup_time() {
	nvim --startuptime log.out
}
