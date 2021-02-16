# frozen_string_literal: true

module Decidim
  module Core
    module HasHastaggableInputFilter
      def self.included(child_class)
        child_class.argument :hashtag,
                             type: GraphQL::Types::String,
                             description: "List result having this hashtag",
                             required: false,
                             prepare: ->(hashtag, _ctx) { "##{hashtag.sub(/^#/, "")}" }
      end
    end
  end
end
