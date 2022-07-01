# frozen_string_literal: true

require "decidim/css_compiler/tailwind/instance"

module Decidim
  module CssCompiler
    module Tailwind
      def write_runtime_configuration
        instance = ::Decidim::CssCompiler::Tailwind::Instance.new
        instance.write_runtime_configuration
      end

      module_function :write_runtime_configuration
    end
  end
end
