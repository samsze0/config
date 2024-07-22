#!/usr/bin/env bash

# Clear all keys in all redis database on current host
redis_clear_all_local_db() {
	redis-cli FLUSHALL
}
