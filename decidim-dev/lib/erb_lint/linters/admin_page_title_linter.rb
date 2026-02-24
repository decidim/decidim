# frozen_string_literal: true

require "erb_lint"
require "erb_lint/linter"
require "erb_lint/linter_config"
require "erb_lint/linter_registry"
require "erb_lint/offense"

module ERBLint
  module Linters
    class AdminPageTitleLinter < Linter
      include LinterRegistry

      TITLE_SNIPPET = '<% add_decidim_page_title(t(".title")) %>'
      TITLE_SNIPPET_REGEX = /\A<%\s*add_decidim_page_title\(t\(".title".*?\)\)\s*%>/

      def run(processed_source)
        return unless admin_view?(processed_source.filename)

        first_line = processed_source.file_content.to_s.lines.first
        return if first_line&.match?(TITLE_SNIPPET_REGEX)

        add_offense(
          processed_source.to_source_range(0...0),
          "Admin views must start with: #{TITLE_SNIPPET}"
        )
      end

      private

      def admin_view?(filename)
        return false unless filename.include?("/app/views/")
        return false unless filename.include?("/admin/")
        return false if filename.include?("/layouts/")
        return false if mailer_view?(filename)
        return false unless filename.end_with?(".html.erb")

        File.basename(filename).start_with?("_") == false
      end

      def mailer_view?(filename)
        filename.include?("/mailer/") || filename =~ %r{/\w+_mailer/}
      end
    end
  end
end
