# frozen_string_literal: true

require "erb_lint"
require "erb_lint/linter"
require "erb_lint/linter_config"
require "erb_lint/linter_registry"
require "erb_lint/offense"

module ERBLint
  module Linters
    class PartialPath < Linter
      include LinterRegistry

      class ConfigSchema < LinterConfig
        property :allowed_prefixes, accepts: Array
      end
      self.config_schema = ConfigSchema

      def run(processed_source)
        file_path = processed_source.filename

        return unless file_path =~ %r{app/views/(.+?)/_?([^/]+)\.html\.erb$}
        return if file_path.include?("/cells/")

        current_directory = Regexp.last_match(1)
        source = processed_source.file_content

        source.scan(/<%=\s*render\s+"([^"]+)"[^%]*%>/) do
          partial_path = Regexp.last_match(1)
          start_pos = Regexp.last_match.begin(1)

          next if partial_path.start_with?("layouts/")
          next if partial_path.start_with?("/")
          next if partial_path.include?("/")

          next if allowed_prefix?(partial_path)

          full_path = "#{current_directory}/#{partial_path}"
          range = processed_source.to_source_range(
            start_pos...(start_pos + partial_path.length)
          )

          add_offense(
            range,
            "Use the full path for partials. Replace `render \"#{partial_path}\"` with `render \"#{full_path}\"`"
          )
        end
      end

      def allowed_prefix?(path)
        return false unless @config.allowed_prefixes

        @config.allowed_prefixes.any? { |prefix| path.start_with?(prefix) }
      end

      def autocorrect(processed_source, offense)
        return unless processed_source.filename =~ %r{app/views/(.+?)/_?([^/]+)\.html\.erb$}
        return if processed_source.filename.include?("/cells/")

        current_directory = Regexp.last_match(1)

        lambda do |corrector|
          partial_path = offense.source_range.source
          full_path = "#{current_directory}/#{partial_path}"
          corrector.replace(offense.source_range, full_path)
        end
      end
    end
  end
end
