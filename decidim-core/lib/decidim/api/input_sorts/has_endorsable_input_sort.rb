# frozen_string_literal: true

module Decidim
  module Core
    module HasEndorsableInputSort
      def self.included(child_class)
        child_class.argument :endorsement_count,
                             type: GraphQL::Types::String,
                             description: "Sort by number of likes, valid values are ASC or DESC",
                             required: false,
                             as: :endorsements_count
      end
    end
  end
end
