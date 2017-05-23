# frozen_string_literal: true

module Decidim
  module Features
    class ExportManifest
      attr_reader :name, :collection, :serializer

      def initialize(name)
        @name = name.to_sym
      end

      def collection(&block)
        if block_given?
          @collection = block
        else
          @collection
        end
      end

      def serializer(serializer = nil, &block)
        if block_given?
          @serializer = Class.new(Decidim::Exporters::Serializer, &block)
        elsif serializer
          @serializer = serializer
        else
          @serializer
        end
      end

      def verify!
        raise "Incomplete manifest!" unless name && collection && serializer
      end
    end
  end
end
