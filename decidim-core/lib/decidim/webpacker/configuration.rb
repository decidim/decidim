# frozen_string_literal: true

module Decidim
  module Webpacker
    class Configuration
      attr_accessor :additional_paths, :entrypoints

      def initialize
        @additional_paths = []
        @entrypoints = {}
      end
    end
  end
end
