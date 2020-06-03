# frozen_string_literal: true

module Decidim
  class ComponentChildren
    class << self
      def register(klass)
        @children_classes ||= []
        @children_classes << klass
      end

      def find_children(query)
        @children_classes.map do |children_class|
          children_class.find_by(query)
        end
      end

      attr_reader :children_classes
    end
  end
end
