# frozen_string_literal: true

require_relative "report"

module Decidim
  module BackportsReporter
    class CLIReport < Decidim::BackportsReporter::Report
      private

      def output_head
        head = "| #{"ID".ljust(6)} | #{"Title".ljust(83)} | Backport v0.27 | Backport v0.26 |\n"
        head += "|#{"-" * 8}|#{"-" * 85}|#{"-" * 16}|#{"-" * 16}|\n"
        head
      end

      def output_line(line)
        output = "| ##{line[:id]} "
        output += "| #{line[:title].ljust(84, " ")}"
        output += "| #{format_backport(line[:related_issues], "v0.27")}"
        output += "| #{format_backport(line[:related_issues], "v0.26")}|\n"
        output
      end

      def format_backport(related_issues, version)
        none = "None".ljust(15, " ")
        return none if related_issues.empty?

        pull_request = extract_backport_pull_request_for_version(related_issues, version)
        return none if pull_request.nil?

        "\e[#{state_color(pull_request[:state])}m##{pull_request[:id]}\e[0m".ljust(24, " ")
      end

      def state_color(state)
        {
          closed: "35",
          merged: "31",
          open: "32"
        }[state.to_sym]
      end
    end
  end
end
