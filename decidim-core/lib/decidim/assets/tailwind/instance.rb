# frozen_string_literal: true

require "ostruct"
require "erb"

module Decidim
  module Assets
    module Tailwind
      class Instance
        def write_runtime_configuration
          evaluated_template = ERB.new(tailwind_configuration_template).result(tailwind_variables.instance_eval { binding })

          File.write(File.join(app_path, "tailwind.config.js"), evaluated_template)
        end

        private

        def tailwind_variables
          # The directories where Tailwind should search for templates are the installed
          # decidim gems and the current directory (which is the Rails app)
          decidim_gems = Bundler.load.specs.select { |spec| spec.name =~ /^decidim-/ }
          content_directories = decidim_gems.push(".")

          # The variable expected by tailwind is a Javascript array of strings
          # The directory globbing with the star is done in Ruby because it was causing an infinite loop
          # when processed by Tailwind
          content_directories_as_array_of_strings = content_directories.map { |content_directory| "'#{content_directory}'" }.join(",")

          OpenStruct.new(tailwind_content_directories: content_directories_as_array_of_strings)
        end

        def tailwind_configuration_template
          File.read(File.expand_path("tailwind.config.js.erb", __dir__))
        end

        def app_path
          @app_path ||=
            if defined?(Rails)
              Rails.application.root
            else
              # This is used when Rails is not available from the webpacker binstubs
              File.expand_path(".", Dir.pwd)
            end
        end
      end
    end
  end
end
