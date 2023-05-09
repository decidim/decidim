# frozen_string_literal: true

module RSpec::Core
  module Notifications
    class SummaryNotification
      # Override the original method to add the full path to the spec file and the correct rspec command to rerun the failed spec
      # The goal is to be able to copy-paste the command to rerun the failed spec without having to manually add the full path to the spec file
      #
      # So, instead of:
      # > rspec ./spec/system/registration_spec.rb:27
      #
      # We get:
      # > bin/rspec ./decidim-core/spec/system/registration_spec.rb:27
      #
      # Original code in rspec-core: https://github.com/rspec/rspec-core/blob/8caecca0b9b299ccbaa5c7ea5dd885ab42cd57d3/lib/rspec/core/notifications.rb#L365
      def colorized_rerun_commands(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
        rspec_command = running_with_rspec_wrapper? ? "bin/rspec" : "rspec"
        "\nFailed examples:\n\n" +
          failed_examples.map do |example|
            colorizer.wrap("#{rspec_command} #{rerun_argument_for(example)}", RSpec.configuration.failure_color) + " " +
              colorizer.wrap("# #{example.full_description}",   RSpec.configuration.detail_color)
          end.join("\n")
      end

      private

      def running_with_rspec_wrapper?
        $0 == "bin/rspec"
      end

      def rerun_argument_for(example)
        if running_with_rspec_wrapper?
          location = location_rerun_argument_for_decidim(example)
        else
          location = example.location_rerun_argument
        end
        return location unless duplicate_rerun_locations.include?(location)

        conditionally_quote(example.id)
      end

      def location_rerun_argument_for_decidim(example)
        absolute_file_path = example.metadata[:absolute_file_path]
        file_path = example.metadata[:file_path][1..-1]
        module_dir = absolute_file_path.gsub(file_path, "").split("/")[-1]

        "./#{module_dir}#{file_path}:#{example.metadata[:line_number]}"
      end
    end
  end
end
