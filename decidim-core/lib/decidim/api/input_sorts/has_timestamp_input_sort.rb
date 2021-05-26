# frozen_string_literal: true

module Decidim
  module Core
    module HasTimestampInputSort
      def self.included(child_class)
        child_class.argument :created_at, GraphQL::Types::String, "Sort by date of creation, valid values are ASC or DESC", required: false
        child_class.argument :updated_at, GraphQL::Types::String, "Sort by date of last modification, valid values are ASC or DESC", required: false
      end
    end
  end
end
