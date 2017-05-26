# frozen_string_literal: true

module Decidim
  module Comments
    # A form object used to create comments from the graphql api.
    #
    class CommentForm < Form
      attribute :body, String
      attribute :alignment, Integer
      attribute :user_group_id, Integer

      mimic :comment

      validates :body, presence: true, length: { maximum: 1000 }
      validates :alignment, inclusion: { in: [0, 1, -1] }, if: ->(form) { form.alignment.present? }
    end
  end
end
