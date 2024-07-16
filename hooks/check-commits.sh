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

local_ref=$(git symbolic-ref HEAD 2>/dev/null)
if [ -z "$local_ref" ]; then
    echo >&2 "Error: You are in a detached HEAD state. Cannot determine the current branch."
    exit 1
fi

local_sha=$(git rev-parse HEAD)
current_branch=$(git rev-parse --abbrev-ref HEAD)
remote_name=$(git remote | head -n 1) # Get the first remote name
remote_ref="${remote_name}/${current_branch}"

# Try to get the SHA of the remote branch
remote_sha=$(git rev-parse "$remote_ref" 2>/dev/null)

# Check the exit status of the last command
if [ $? -ne 0 ]
then
    # git rev-parse failed, so the remote branch does not exist
    remote_sha=$z40
fi

if [ "$local_sha" = "$z40" ]
then
    # Handle delete
    echo >&2 "Error: Local SHA is zero hash. This might indicate a deleted branch."
    exit 1
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
