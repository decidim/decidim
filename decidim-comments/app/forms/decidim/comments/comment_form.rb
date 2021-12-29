# frozen_string_literal: true

module Decidim
  module Comments
    # A form object used to create comments from the graphql api.
    #
    class CommentForm < Form
      attribute :body, Decidim::Attributes::CleanString
      attribute :alignment, Integer
      attribute :user_group_id, Integer
      attribute :commentable
      attribute :commentable_gid

      mimic :comment

      validates :body, presence: true, length: { maximum: ->(form) { form.max_length } }
      validates :alignment, inclusion: { in: [0, 1, -1] }, if: ->(form) { form.alignment.present? }

      validate :max_depth

      def max_length
        if current_component.try(:settings).respond_to?(:comments_max_length)
          component_length = current_component.try { settings.comments_max_length.positive? }
          return current_component.settings.comments_max_length if component_length
        end
        return current_organization.comments_max_length if current_organization.comments_max_length.positive?

        1000
      end

      def max_depth
        return unless commentable.respond_to?(:depth)

        errors.add(:base, :invalid) if commentable.depth >= Comment::MAX_DEPTH
      end
    end
  end
end
