# frozen_string_literal: true

module Decidim
  module Comments
    # A form object used to create comments from the graphql api.
    #
    class CommentForm < Form
      attribute :body, String
      attribute :alignment, Integer
      attribute :user_group_id, Integer
      attribute :commentable

      mimic :comment

      validates :body, presence: true, length: { maximum: 1000 }
      validates :alignment, inclusion: { in: [0, 1, -1] }, if: ->(form) { form.alignment.present? }

      validate :max_depth

      def max_depth
        return unless commentable.respond_to?(:depth)

        errors.add(:base, :invalid) if commentable.depth >= Comment::MAX_DEPTH
      end
    end
  end
end
