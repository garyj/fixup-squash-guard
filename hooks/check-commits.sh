#!/bin/sh

# Script to prevent git push when there are `fixup!` or `squash!` commits in the branch
#
# Inspired by: https://github.com/torproject/tor/pull/530/files

z40=0000000000000000000000000000000000000000

check_commit() {
    commit_type=$1
    commit=$(git rev-list -n 1 --grep "^$commit_type!" "$range")
    if [ -n "$commit" ]
    then
        echo >&2 "Found $commit_type! commit in $local_ref, not pushing"
        echo >&2 "If you really want to push this, use --no-verify."
        exit 1
    fi
}

local_ref=$(git symbolic-ref HEAD)
local_sha=$(git rev-parse HEAD)
remote_ref="origin/$(git rev-parse --abbrev-ref HEAD)" # Assumes remotes is named origin
remote_sha=$(git rev-parse "$remote_ref" 2>/dev/null)

if [ -z "$remote_sha" ]
then
    # Remote branch does not exist, use zero SHA
    remote_sha=$z40
fi

if [ "$local_sha" = "$z40" ]
then
    # Handle delete
    :
else
    if [ "$remote_sha" = "$z40" ]
    then
        # New branch, examine all commits
        range="$local_sha"
    else
        # Update to existing branch, examine new commits
        range="$remote_sha..$local_sha"
    fi

    # Check for fixup! and squash! commits
    check_commit "fixup"
    check_commit "squash"
fi

exit 0
