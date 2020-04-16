# frozen_string_literal: true

module Decidim
  module Core
    module HasEndorsableInputSort
      def self.included(child_class)
        child_class.argument :endorsement_count,
                             type: String,
                             description: "Sort by number of endorsements, valid values are ASC or DESC",
                             required: false,
                             prepare: ->(value, _ctx) do
                                        { endorsements_count: value }
                                      end
      end
    end
  end
end
