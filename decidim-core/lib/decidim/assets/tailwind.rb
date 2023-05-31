# frozen_string_literal: true

module Decidim
  module Assets
    module Tailwind
      autoload :Instance, "decidim/assets/tailwind/instance"

      def write_runtime_configuration
        instance = ::Decidim::Assets::Tailwind::Instance.new
        instance.write_runtime_configuration
      end

      module_function :write_runtime_configuration
    end
  end
end
