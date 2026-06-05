#!/usr/bin/env ruby
# frozen_string_literal: true

# This script updates the decidim-generators Gemfile.lock to be in sync with the Gemfile.lock in the root.
require "English"
require "open3"

base_sha, head_sha = ARGV
abort "Usage: #{$PROGRAM_NAME} BASE_SHA HEAD_SHA" unless base_sha && head_sha

sha_re = /\A[0-9a-f]{7,40}\z/i
abort "Invalid SHA input" unless base_sha.match?(sha_re) && head_sha.match?(sha_re)

stdout, stderr, status = Open3.capture3("git", "diff", base_sha, head_sha, "--", "Gemfile.lock")
abort "git diff failed: #{stderr}" unless status.success?
diff_output = stdout

# Look for both additions (+) and removals (-) that indicate version changes
changed_gems = diff_output.each_line
                          .grep(/^[+-]    [A-Za-z0-9_.-]+ \(/)
                          .map { |line| line.split[1] }
                          .uniq
                          .sort

if changed_gems.empty?
  puts "No gem changes detected."
  exit 0
end

puts "Updating: #{changed_gems.join(", ")}"

Dir.chdir("decidim-generators") do
  changed_gems.each do |gem|
    warn("Failed to update #{gem}: exit status #{$CHILD_STATUS.exitstatus}") unless system("bundle", "update", "--quiet", gem)
  end
end
