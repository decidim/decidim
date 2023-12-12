# frozen_string_literal: true

module Decidim
  module Dev
    class DummySerializer
      def initialize(id)
        @id = id
      end

      def run
        serialize
      end

      def serialize
        {
          id: @id
        }
      end
    end
  end
end
