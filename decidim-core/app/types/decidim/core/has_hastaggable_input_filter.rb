# frozen_string_literal: true

module Decidim
  module Core
    module HasHastaggableInputFilter
      def self.included(child_class)
        child_class.argument :hashtag,
                             type: String,
                             description: "List result having this hashtag",
                             required: false,
                             prepare: ->(hashtag, _ctx) do
                               { attr: :hashtag, func: :eq, value: "##{hashtag.sub(/^#/, "")}" }
                             end
      end
    end
  end
end
