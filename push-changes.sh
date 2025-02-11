#!/bin/bash
home=$(pwd)
cd "$REPO_PATH" || exit
git reset --hard
git pull --all
git checkout "$BRANCH" -- || git switch --orphan "$BRANCH"
if [ "$CLEAR" == "true" ]
then
    git rm -rfq -- *
else
    while IFS="" read -r pattern
        do
            rm -rf -- "$pattern"
        done <<< "$(grep '\S' <<< "$RM_LIST")"
fi
rsync -a --exclude=".git" ../"$STAGING"/ ./
git add -A
git commit -m "$MESSAGE"
git push -u origin "$BRANCH"
cd "$home" || exit
