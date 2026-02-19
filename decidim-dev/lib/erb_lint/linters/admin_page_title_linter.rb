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

      def run(processed_source)
        return unless admin_view?(processed_source.filename)

        first_line = processed_source.file_content.to_s.lines.first
        return if first_line&.start_with?(TITLE_SNIPPET)

        add_offense(
          processed_source.to_source_range(0...0),
          "Admin views must start with: #{TITLE_SNIPPET}"
        )
      end

      private

      def admin_view?(filename)
        return false unless filename.include?("/app/views/")
        return false unless filename.include?("/admin/")
        return false unless filename.end_with?(".html.erb")

        File.basename(filename).start_with?("_") == false
      end
    end
  end
end
