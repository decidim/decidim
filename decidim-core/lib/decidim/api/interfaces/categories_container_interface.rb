# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a resource that contains categories.
    module CategoriesContainerInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in objects that contain categories."

      field :categories, [Decidim::Core::CategoryType, { null: true }], "Categories for this space", null: false do
        argument :filter, Decidim::Core::CategoryInputFilter, "Provides several methods to filter the results", required: false
      end

      def categories(filter: {})
        CategoryList.new.call(object, { filter: }, context)
      end
    end
  end
end
