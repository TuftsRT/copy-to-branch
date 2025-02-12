#!/bin/bash
while IFS="|" read -r find replace glob
do
    if [ -n "$find" ]; then
        # shellcheck disable=SC2086
        find "$STAGING"/$glob -type f -exec sed -i "s|$find|$replace|g" {} +
    fi
done <<< "$(grep '\S' <<< "$INPUTS_REPLACE")"
