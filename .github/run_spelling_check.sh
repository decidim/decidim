#!/bin/bash

if ! command -v yq &> /dev/null; then
  echo "The yq command is not available on this system."
  echo "Please install yq to use this script."
  echo "See: https://github.com/mikefarah/yq/#install"
  exit 1
fi

# Read the configurations from the YAML file
CONFIG_FILE=".spelling.yml"

declare -A forbidden_words=()
while read forbidden; do
  word=$(echo $forbidden | cut -d'=' -f 1)
  preferred=$(echo $forbidden | cut -d'=' -f 2-)
  forbidden_words["$word"]="$preferred"
done < <(yq '.forbidden | to_entries | map([.key, .value] | join("=")) | .[]' "$CONFIG_FILE")

forbidden_words_file=$(mktemp)
trap 'rm -f $forbidden_words_file' EXIT

printf "%s\n" "${!forbidden_words[@]}" | sort > $forbidden_words_file

exclude_paths=($(yq '.exclude_paths[]' "$CONFIG_FILE"))
exclude_paths_pattern=$(printf "|(%s)" "${exclude_paths[@]}" | cut -c 2-)

# Perform grep and iterate through all matches
status=0

while read match; do
  status=1

  # Cut the relevant parts of the match
  file=$(echo $match | cut -d':' -f 1)
  line=$(echo $match | cut -d':' -f 2)
  text=$(sed "${line}!d" "$file")

  # Find the forbidden words
  for word in "${!forbidden_words[@]}"; do
    len=$(expr length "$word")
    preferred=${forbidden_words[$word]}

    while read posmatch; do
      spos=$(( $(echo $posmatch | cut -d':' -f 1) + 1 ))
      epos=$(( $spos + $len ))

      # Print out the annotation messages
      # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
      echo "::error file=${file},line=${line},col=${spos},endColumn=${epos}::Use \"$preferred\" instead of \"$word\"."
    done < <(echo "$text" | grep -owib "$word")
  done
done < <(find decidim-* -type f | grep -vP "$exclude_paths_pattern" | xargs -n1000 grep -Hnwif $forbidden_words_file)

exit $status
