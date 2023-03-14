#!/bin/bash

forbidden_words=$(mktemp)

cat <<EOT | sort > $forbidden_words
aren't
can't
couldn't
didn't
doesn't
don't
hasn't
haven't
isn't
shouldn't
wasn't
weren't
won't
EOT

exclude_paths=(
  "decidim-dev/lib/decidim/dev/assets/participatory_text.md"
  "decidim-core/lib/decidim/db/common-passwords.txt"
  "decidim-initiatives/spec/types/initiative_type_spec.rb"
  "decidim-proposals/app/packs/documents/decidim/proposals/participatory_texts/participatory_text.md"
  "config/locales/((?!en).)*\.yml"
)
exclude_paths_pattern=$(printf "|(%s)" "${exclude_paths[@]}" | cut -c 2-)

trap 'rm -f $forbidden_words' EXIT

status=0

# Perform grep and iterate through all matches
while read match; do
  status=1

  # Cut the relevant parts of the match
  file=$(echo $match | cut -d':' -f 1)
  line=$(echo $match | cut -d':' -f 2)
  text=$(sed "${line}!d" "$file")

  # Find the forbidden words
  for word in $(cat $forbidden_words); do
    len=$(expr length "$word")

    while read posmatch; do
      spos=$(( $(echo $posmatch | cut -d':' -f 1) + 1 ))
      epos=$(( $spos + $len ))

      # Print out the annotation messages
      # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
      echo "::error file=${file},line=${line},col=${spos},endColumn=${epos}::The following word is forbidden $word"
    done < <(echo "$text" | grep -oib "$word")
  done
done < <(find decidim-* -type f | grep -vP "$exclude_paths_pattern" | xargs -n1000 grep -Hnif $forbidden_words)

exit $status
