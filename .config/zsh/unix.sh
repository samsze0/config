#!/usr/bin/env bash

# Print full system info w/ `uname -a`
system_info() {
	uname -a
}

# When the setuid bit is set on an executable file, users who run that file gain the same permissions as the owner of the file
add_setuid_bit() {
	chmod u+s "$@"
}

# When the setgid bit is set on an executable file, the group which the user who run that file belong gain the same permissions as the owner of the file
add_setgid_bit() {
	chmod g+s "$@"
}

# When the sticky bit is set on a directory, only the owner of a file in that directory can rename or delete the file
add_setsticky_bit() {
	chmod +t "$@"
}

# Show partition table
partition_info() {
	sfdisk -l
}

# Show block devices info
block_devices_info() {
	lsblk
}

# Format disk
format_disk() {
	mkfs -t ext4 "$@"
}

# List all processes
fzf_process() {
	ps aux | fzf # a: show processes for all users; x: show also the processes not attached to a terminal; u: formatting
}

lsiommu() {
	# Check if on linux, if not, exit with error
	if [ "$(uname)" != "Linux" ]; then
		echo "This script is for Linux only"
		return 1
	fi

	for d in $(find /sys/kernel/iommu_groups/ -type l | sort -n -k5 -t/); do
		n=${d#*/iommu_groups/*}
		n=${n%%/*}
		printf 'IOMMU Group %s ' "$n"
		lspci -nns "${d##*/}"
	done
}

iommu() {
	# Check if on linux, if not, exit with error
	if [ "$(uname)" != "Linux" ]; then
		echo "This script is for Linux only"
		return 1
	fi

	shopt -s nullglob
	lastgroup=""
	for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
		for d in $g/devices/*; do
			if [ "${g##*/}" != "$lastgroup" ]; then
				echo -en "Group ${g##*/}:\t"
			else
				echo -en "\t\t"
			fi
			lastgroup=${g##*/}
			lspci -nms ${d##*/} | awk -F'"' '{printf "[%s:%s]", $4, $6}'
			if [[ -e "$d"/reset ]]; then echo -en " [R] "; else echo -en "     "; fi

			lspci -mms ${d##*/} | awk -F'"' '{printf "%s %-40s %s\n", $1, $2, $6}'
			for u in ${d}/usb*/; do
				bus=$(cat "${u}/busnum")
				lsusb -s $bus: |
					awk '{gsub(/:/,"",$4); printf "%s|%s %s %s %s|", $6, $1, $2, $3, $4; for(i=7;i<=NF;i++){printf "%s ", $i}; printf "\n"}' |
					awk -F'|' '{printf "USB:\t\t[%s]\t\t %-40s %s\n", $1, $2, $3}'
			done
		done
	done
}

list_disk_name_id_mappings() {
	ls -l /dev/disk/by-id/* | grep -v part | awk '{print $9, $10, $11}' | sed 's/\.\.\/\.\.\//\/dev\//'
}

list_kernel_supported_filesystems() {
	ls /lib/modules/$(uname -r)/kernel/fs
}

md5_dir() {
  find "$1" -type f -exec md5sum {} + | md5sum
}

dir_size() {
  du -sh "$1"
}

diff_dir_with_progress() {
  diff -rqs "$1" "$2" | pv -l -s "$(find "$1" -type f | wc -l)" > /dev/null
}
