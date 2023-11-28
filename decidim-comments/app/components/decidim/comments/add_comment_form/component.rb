# frozen_string_literal: true

module Decidim
  module Comments
    module AddCommentForm
      class Component < Decidim::BaseComponent
        def initialize(commentable:, **options)
          @commentable = commentable
          @options = options.with_defaults(root_depth: 0, order: "older")
        end

        private

        attr_reader :commentable, :options

        delegate :commentable_type, :comments_have_alignment?, to: :commentable
        delegate :decidim_comments, to: :helpers
        def root_depth = options[:root_depth]

        def order = options[:order]

        def form_id = "new_comment_for_#{commentable_type.demodulize}_#{commentable.id}"

        def add_comment_id = "add-comment-#{commentable_type.demodulize}-#{commentable.id}"

        def reply? = commentable.is_a?(Decidim::Comments::Comment)

        class CommentAsComponent < Decidim::BaseComponent
          def initialize(commentable, form)
            @commentable = commentable
            @form = form
          end

          private

          attr_reader :form, :commentable

          delegate :commentable_type, to: :commentable

          def comment_as_id = "add-comment-#{commentable_type.demodulize}-#{commentable.id}-user-group-id"

          def render? = verified_user_groups.any?

          def verified_user_groups
            return [] unless current_user

            @verified_user_groups ||= Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
          end

          def comment_as_options
            [[current_user.name, ""]] + verified_user_groups.map do |group|
              [group.name, group.id]
            end
          end
        end

        class OpinionComponent < Decidim::BaseComponent
          def initialize(commentable)
            @commentable = commentable
          end

          private

          attr_reader :commentable

          delegate :comments_have_alignment?, to: :commentable
          def render? = comments_have_alignment?
        end

        def form_object
          Decidim::Comments::CommentForm.new(
            commentable_gid: commentable.to_signed_global_id.to_s,
            alignment: 0
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
