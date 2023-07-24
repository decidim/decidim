# frozen_string_literal: true

module Decidim
  module BackportsReporter
    # Abstract class for the different formats
    class Report
      attr_reader :report, :last_version_number

      def initialize(report:, last_version_number:)
        @report = report
        @last_version_number = last_version_number
      end

      def call = output_report

      private

      def penultimate_version_number
        major, minor = last_version_number.split(".")

        "#{major}.#{minor.to_i - 1}"
      end

      def output_report
        output = output_head
        report.each do |line|
          output += output_line(line)
        end
        output
      end

      def output_head = raise "Called abstract method: output_head"

      def output_line(_line) = raise "Called abstract method: output_line"

      def extract_backport_pull_request_for_version(related_issues, version)
        related_issues = related_issues.select do |pull_request|
          pull_request[:title].start_with?("Backport") && pull_request[:title].include?(version)
        end
        return if related_issues.empty?

        related_issues.first
      end
    end
  end
end
