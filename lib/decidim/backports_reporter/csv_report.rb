# frozen_string_literal: true

require_relative "report"

module Decidim
  module BackportsReporter
    class CSVReport < Decidim::BackportsReporter::Report
      private

      def output_head = "ID;Title;Backport v0.27;Backport v0.26\n"

      def output_line(line)
        output = "#{line[:id]};"
        output += "#{line[:title]};"
        output += "#{format_backport(line[:related_issues], "v0.27")};"
        output += "#{format_backport(line[:related_issues], "v0.26")}\n"
        output
      end

      def format_backport(related_issues, version)
        return if related_issues.empty?

        pull_request = extract_backport_pull_request_for_version(related_issues, version)
        return if pull_request.nil?

        "#{pull_request[:state]}|#{pull_request[:id]}"
      end
    end
  end
end
