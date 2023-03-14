#!/bin/bash

forbidden_words=$(mktemp)
excluded_paths=$(mktemp)

cat <<EOT > $forbidden_words
can't
doesn't
haven't
didn't
couldn't
won't
hasn't
isn't
aren't
don't
wasn't
shouldn't
weren't
EOT

# Actual excluded paths
# decidim-dev/lib/decidim/dev/assets/participatory_text.md
# decidim-core/lib/decidim/db/common-passwords.txt
# decidim-initiatives/spec/types/initiative_type_spec.rb
# decidim-proposals/app/packs/documents/decidim/proposals/participatory_texts/participatory_text.md

cat <<EOT > $excluded_paths
decidim-core/lib/decidim/db/common-passwords.txt
this-should-include-actual-file-paths
for-testing-purposes-this-is-disabled
EOT

trap 'rm -f $forbidden_words $excluded_paths' EXIT

status=0

# Perform grep and iterate through all matches
while read match ; do
  status=1

  # Cut the relevant parts of the match
  file=$(echo $match | cut -d':' -f 1)
  line=$(echo $match | cut -d':' -f 2)
  text=$(echo $match | cut -d':' -f 3-)

  # Find the forbidden words
  words=()
  for word in $(cat $forbidden_words); do
    if [[ $text == *"$word"* ]]; then
      words+=("$word")
    fi
  done

  # Create the message based on the amount of matching words
  message=""
  if [[ ${#words[@]} -gt 1 ]]; then
    message="The following words are forbidden:"
  else
    message="The following word is forbidden:"
  fi

  # Print out the annotation messages
  # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
  message_words=$(printf ", %s" "${words[@]}")
  echo "::error file=${file},line=${line}::${message} ${message_words:2}"
done < <(find decidim-* -type f | grep -vf $excluded_paths | xargs -n1000 grep -Hnif $forbidden_words)

exit $status
