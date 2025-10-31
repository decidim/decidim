# frozen_string_literal: true

module Decidim
  module Surveys
    class BatchesArray
      def initialize(array)
        @array = array
      end

      def find_in_batches(batch_size: 1000, &)
        @array.each_slice(batch_size, &)
      end

      def count
        @array.size
      end

      def method_missing(method, *, &)
        @array.send(method, *, &)
      end

      def respond_to_missing?(method, include_private = false)
        @array.respond_to?(method, include_private) || super
      end
    end
  end
end
