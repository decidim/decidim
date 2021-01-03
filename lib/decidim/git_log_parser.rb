# frozen_string_literal: true

require "decidim/dev"

module Decidim
  #
  # Parses git-log entries in pretty format and produces CHANGELOG entries.
  class GitLogParser
    #
    # Arguments:
    # full_log - In expected format as outputted by git-log for the following command:
    #   git log 7579b34f55e4dcfff43c160edbbf14a32bf643b2..HEAD --pretty=format:"commit %h%n%n%s%n%nNotes:%n%n%N"  > full_log
    #
    def initialize(full_log)
      return if full_log.blank?

      @entries = full_log.split(/^commit \w+[^\n]*$/)
      @entries.shift # remove first empty entry from split
      puts "Found #{@entries.size} entries"
    end

    attr_reader :categorized, :uncategorized

    def parse
      return unless @entries

      @categorized = {}
      @uncategorized = []
      @entries.each do |entry|
        content, notes = entry.split(/^Notes:$/)
        content = content.strip
        content = content.gsub(/\(#(\d+)\)$/) { "[\\##{Regexp.last_match(1)}](https://github.com/decidim/decidim/pull/#{Regexp.last_match(1)})" }
        notes = notes&.strip
        if notes.present?
          type, modules = notes.split(":")
          @categorized[type] ||= []
          @categorized[type] << "- #{modules.strip}: #{content}"
        else
          next if content.start_with?("New Crowdin updates")

          @uncategorized << content
        end
      end
    end

    def print_results
      puts "CHANGELOG ENTRIES:"
      @categorized.keys.each do |type|
        puts "#{type}:"
        @categorized[type].each do |entry|
          puts entry
        end
      end
      puts "UNCATEGORIZED ENTRIES:"
      puts uncategorized.join("\n")
    end
  end
end
