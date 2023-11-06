# frozen_string_literal: true

require "active_support/core_ext/string/filters"
require_relative "report"

module Decidim
  module BackportsReporter
    class CLIReport < Decidim::BackportsReporter::Report
      private

      def output_head
        head = "| #{"ID".center(6)} | #{"Title".center(83)} | Backport v#{last_version_number} | Backport v#{penultimate_version_number} |\n"
        head += "|#{"-" * 8}|#{"-" * 85}|#{"-" * 16}|#{"-" * 16}|\n"
        head
      end

      def output_line(line)
        output = "| ##{line[:id].to_s.center(5)} "
        output += "| #{line[:title].truncate(83).ljust(84, " ")}"
        output += "| #{format_backport(line[:related_issues], "v#{last_version_number}")}"
        output += "| #{format_backport(line[:related_issues], "v#{penultimate_version_number}")}|\n"
        output
      end

      def format_backport(related_issues, version)
        none = "None".center(15, " ")
        return none if related_issues.empty?

        pull_request = extract_backport_pull_request_for_version(related_issues, version)
        return none if pull_request.nil?

        "\e[#{state_color(pull_request[:state])}m##{pull_request[:id]}\e[0m".center(24, " ")
      end

      def state_color(state)
        {
          closed: "35",
          merged: "34",
          open: "32"
        }[state.to_sym]
      end
    end
  end
end
