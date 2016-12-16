# frozen_string_literal: true
module Decidim
  module Comments
    # A form object used to create comments from the graphql api.
    #
    class CommentForm < Form
      attribute :body, String
      attribute :alignment, Integer

      mimic :comment

      validates :body, presence: true
      validates :alignment, inclusion: { in: [0, 1, -1] }, if: ->(form) { form.alignment.present? }
    end
  end
end
