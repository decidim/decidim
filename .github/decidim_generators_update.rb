#!/usr/bin/env ruby
# frozen_string_literal: true

# This script updates the decidim-generators Gemfile.lock to be in sync with the Gemfile.lock in the root.

require "open3"

base_sha, head_sha = ARGV
abort "Usage: #{$0} BASE_SHA HEAD_SHA" unless base_sha && head_sha

diff_output = `git diff #{base_sha} #{head_sha} -- Gemfile.lock`

# Look for both additions (+) and removals (-) that indicate version changes
changed_gems = diff_output.each_line
                          .select { |line| line.match?(/^[+-]    [A-Za-z0-9_.-]+ \(/) }
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
    system("bundle", "update", "--quiet", gem) ||
      warn("Failed: #{gem}")
  end
end
