# frozen_string_literal: true
module Decidim
  module Exporters
    class Serializer
      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def serialize
        raise NotImplementedError
      end
    end
  end
end
