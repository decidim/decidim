# frozen_string_literal: true

module Decidim
  module Comments
    module EditComment
      class Component < Decidim::BaseComponent
        def initialize(commentable:, options: {})
          @commentable = commentable
          @options = options.with_defaults(root_depth: 0)
        end

        private

        attr_reader :commentable, :options

        delegate :decidim_comments, to: :helpers

        include Decidim::ModalHelper

        def render? = commentable.authored_by?(current_user)

        def form_id = "edit_comment_#{commentable.id}"

        def form_object
          Decidim::Comments::CommentForm.new(
            body: commentable.translated_body
          )
        end

        def comments_max_length
          return 1000 unless commentable.respond_to?(:component)
          return component_comments_max_length if component_comments_max_length
          return organization_comments_max_length if organization_comments_max_length

          1000
        end

        def component_comments_max_length
          return unless commentable.component&.settings.respond_to?(:comments_max_length)

          commentable.component.settings.comments_max_length if commentable.component.settings.comments_max_length.to_i.positive?
        end

        def organization_comments_max_length
          return unless organization

          organization.comments_max_length if organization.comments_max_length.to_i.positive?
        end

        def organization
          return commentable.organization if commentable.respond_to?(:organization)

          commentable.component.organization if commentable.component.organization.comments_max_length.positive?
        end
      end
    end
  end
end
