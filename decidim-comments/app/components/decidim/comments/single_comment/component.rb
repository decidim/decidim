# frozen_string_literal: true

module Decidim
  module Comments
    module SingleComment
      class Component < Decidim::BaseComponent
        with_collection_parameter :comment

        def initialize(comment:, **options)
          @comment = comment
          @options = options.with_defaults(root_depth: 0, order: "older")
        end

        private

        attr_reader :comment, :options

        delegate :created_at, :formatted_body, :alignment, :root_commentable, :edited?, :has_replies_in_children?, to: :comment
        delegate :decidim_comments, to: :helpers

        include Decidim::ResourceHelper

        def comment_path = decidim_comments.comment_path(comment)

        def reloaded? = options[:reloaded]

        def reply_id = "comment#{comment.id}-reply"

        def context_menu_id = "toggle-context-menu-#{comment.id}"

        def root_depth = options[:root_depth]

        def order = options[:order]

        def replies
          SortedComments.for(comment, order_by: options[:order])
        end

        def commentable_path(params = {})
          if defined?(Decidim::Budgets) && root_commentable.is_a?(Decidim::Budgets::Project)
            resource_locator([root_commentable.budget, root_commentable]).path(params)
          else
            resource_locator(root_commentable).path(params)
          end
        end

        def author_presenter
          if comment.author.respond_to?(:official?) && comment.author.official?
            Decidim::Core::OfficialAuthorPresenter.new
          elsif comment.user_group
            comment.user_group.presenter
          else
            comment.author.presenter
          end
        end

        class DeletedCommentComponent < Decidim::BaseComponent
          def initialize(comment, options = {})
            @comment = comment
            @options = options.with_defaults(root_depth: 0, reloaded: false, order: "older")
          end

          private

          attr_reader :comment, :options

          delegate :has_replies_in_children?, to: :comment
          def render? = comment.deleted?

          def reloaded? = options[:reloaded]

          def root_depth = options[:root_depth]

          def order = options[:order]

          def replies
            SortedComments.for(comment, order_by: options[:order])
          end
        end

        class AlignmentBadgeComponent < Decidim::BaseComponent
          def initialize(alignment)
            @alignment = alignment
          end

          private

          attr_reader :alignment

          def render? = [-1, 1].include?(alignment)

          def alignment_badge_classes
            classes = %w(label alignment)
            case alignment
            when 1
              classes << "success"
            when -1
              classes << "alert"
            end
            classes.join(" ")
          end

          def alignment_badge_label
            if alignment == 1
              I18n.t("decidim.components.comment.alignment.in_favor")
            else
              I18n.t("decidim.components.comment.alignment.against")
            end
          end
        end

        class ActionsComponent < Decidim::BaseComponent
          def initialize(comment, options = {})
            @comment = comment
            @options = options.with_defaults(root_depth: 0, order: "older")
          end

          attr_reader :comment, :options

          delegate :has_replies_in_children?, :accepts_new_comments?, :root_commentable, to: :comment

          def root_depth = options[:root_depth]

          def depth = comment.depth - root_depth

          def reply_id = "comment#{comment.id}-reply"

          def replies
            SortedComments.for(comment, order_by: options[:order])
          end

          delegate :user_signed_in?, to: :helpers

          def can_reply?
            user_signed_in? && accepts_new_comments? &&
              root_commentable.user_allowed_to_comment?(current_user)
          end
        end

        class VotesComponent < Decidim::BaseComponent
          def initialize(comment, options = {})
            @comment = comment
            @options = options
          end

          private

          include Decidim::ActionAuthorizationHelper

          attr_reader :comment, :options

          delegate :root_commentable, to: :comment
          delegate :user_signed_in?, :current_user, :action_authorized_to, :decidim_comments, to: :helpers

          def render? = root_commentable.comments_have_votes?

          def up_votes_count = comment.up_votes.count

          def down_votes_count = comment.down_votes.count

          def voted_up? = comment.up_voted_by?(current_user)

          def voted_down? = comment.down_voted_by?(current_user)

          # action_authorization_button expects current_component to be available
          def current_component = root_commentable.try(:component)

          def vote_button_to(path, params, &)
            # actions are linked to objects belonging to a component
            # To apply :comment permission, the modal authorizer should be refactored to allow participatory spaces-level comments
            return button_to(path, params, &) unless current_component

            action_authorized_button_to(:vote_comment, path, params.merge(resource: root_commentable), &)
          end

          def votes_up_classes
            classes = ["button button__sm button__text-secondary js-comment__votes--up"]
            classes << "is-vote-selected" if voted_up?
            classes << "is-vote-notselected" if voted_down?
            classes.join(" ")
          end

          def votes_down_classes
            classes = ["button button__sm button__text-secondary js-comment__votes--down"]
            classes << "is-vote-selected" if voted_down?
            classes << "is-vote-notselected" if voted_up?
            classes.join(" ")
          end
        end

        delegate :accepts_new_comments?, to: :comment
        delegate :user_signed_in?, to: :helpers
        def can_reply?
          user_signed_in? && accepts_new_comments? &&
            root_commentable.user_allowed_to_comment?(current_user)
        end
      end
    end
  end
end
