#!/bin/sh
FS="tests/filesystem.squashfs"
REMOVE="tests/filesystem.manifest-remove"

if ! test -e "target/debug/distinst"; then
    cargo build --bin distinst
fi

if ! test "${1}"; then
    echo "must provide a block device as an argument"
    exit 1
fi

if ! test -b "${1}"; then
    echo "provided argument is not a block device"
    exit 1
fi

for file in "$FS" "$REMOVE"; do
    if ! test -e "${file}"; then
        echo "failed to find ${file}"
        exit 1
    fi
done

set -x

sudo target/debug/distinst \
    -s "${FS}" \
    -r "${REMOVE}" \
    -h "pop-testing" \
    -k "us" \
    -l "en_US.UTF-8" \
    -b "$1" \
    -t "$1:gpt" \
    -n "$1:primary:start:512M:fat32:/boot/efi:esp" \
    -n "$1:primary:512M:-512M:ext4:/" \
    -n "$1:primary:-512M:end:swap"