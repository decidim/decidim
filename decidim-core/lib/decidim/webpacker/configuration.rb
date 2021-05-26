# frozen_string_literal: true

module Decidim
  module Webpacker
    class Configuration
      attr_accessor :additional_paths

      def initialize
        @additional_paths = []
      end
    end
  end
end
