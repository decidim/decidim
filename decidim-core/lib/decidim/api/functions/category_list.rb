# frozen_string_literal: true

module Decidim
  module Core
    # An abstract resolver for the GraphQL category endpoints inside a
    # participatory_space. Used in the keyword "categories", ie:
    #
    # participatoryProcesses {
    #   categories(filter: { parentId: "1" }) {...}
    # }
    #
    # Needs to be extended and add arguments.
    #
    # This is used by ParticipatorySpaceInterface to apply filter categories
    # searches.
    class CategoryList
      include NeedsApiFilterAndOrder
      attr_reader :model_class

      def initialize
        @model_class = Decidim::Category
      end

      def call(participatory_space, args, _ctx)
        @query = participatory_space.categories
        add_filter_keys(args[:filter])
        @query
      end
    end
  end
end
