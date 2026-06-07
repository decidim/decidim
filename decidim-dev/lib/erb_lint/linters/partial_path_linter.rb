# frozen_string_literal: true

require "erb_lint"
require "erb_lint/linter"
require "erb_lint/linter_config"
require "erb_lint/linter_registry"
require "erb_lint/offense"

module ERBLint
  module Linters
    # Lint ERB partial paths.
    #
    # This linter ensures that partials are rendered with their full path
    # relative to the views directory. For example, in app/views/posts/index.html.erb,
    # it will flag `render "post"` and suggest `render "posts/post"`.
    #
    # It allows configuring prefixes that are exempt from this rule via
    # the `allowed_prefixes` configuration option.
    class PartialPath < Linter
      include LinterRegistry

      # Configuration schema for the PartialPath linter.
      #
      # @!attribute allowed_prefixes
      #   @return [Array<String>] List of prefixes that are allowed to be used without full path
      class ConfigSchema < LinterConfig
        property :allowed_prefixes, accepts: Array
      end
      self.config_schema = ConfigSchema

      # Runs the linter on the given processed source.
      #
      # This method scans the source code for ERB render calls and checks if they
      # are using the full path for partials. If not, it adds an offense.
      #
      # @param processed_source [ERBLint::ProcessedSource] The processed source to lint
      # @return [void]
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

      # Checks if the given path starts with any of the allowed prefixes.
      #
      # @param path [String] The partial path to check
      # @return [Boolean] true if the path starts with an allowed prefix, false otherwise
      def allowed_prefix?(path)
        return false unless @config.allowed_prefixes

        @config.allowed_prefixes.any? { |prefix| path.start_with?(prefix) }
      end

      # Generates the autocorrection lambda for the given offense.
      #
      # This method creates a lambda that will replace the partial path with its
      # full path when the linter's autocorrect feature is used.
      #
      # @param processed_source [ERBLint::ProcessedSource] The processed source containing the offense
      # @param offense [ERBLint::Offense] The offense to generate a correction for
      # @return [Proc, nil] A lambda that performs the correction, or nil if correction is not possible
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
