#!/bin/bash
set -e

git checkout folsom

# If we're not on master anywhere, pulling master doesn't make sense
echo Checking if all submodules are on branch folsom
if ! git submodule foreach -q "git branch | grep -q '* folsom'"
then
    echo The submodule above is not on branch folsom.
    echo You can try: \"git submodule foreach git checkout folsom\" and rerun ./pull-all.sh
    exit 1
fi

# If we have uncommitted changes anywhere, they'll be lost.
echo Checking if submodules don\'t have uncommitted changes
if ! git submodule foreach -q 'if (git status -s | grep .); then echo You have uncommitted changes in $path, they would be lost; return 1; fi'
then
    echo The submodule above has uncommitted changes which would be lost by pulling.
    echo Please navigate there and commit, then rerun ./pull-all.sh
    exit 1
fi

# If we have local unpushed changes, they'll be lost too.
echo Checking if submodules don\'t have unpushed changes
if ! git submodule foreach -q 'git rev-parse folsom | grep -q $(git merge-base folsom origin/folsom)'
then
    echo The submodule above has unpushed changes which would be lost by pulling.
    echo \(branch folsom is not an ancestor of origin/folsom\)
    echo Please do ./push-all.sh first, then rerun ./pull-all.sh
    exit 1
fi

git pull 
git submodule update --init --merge

