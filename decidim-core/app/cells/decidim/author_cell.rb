# frozen_string_literal: true

module Decidim
  # This cell renders the author of a resource. It is intended to be used
  # below resource titles to indicate its authorship & such, and is intended
  # for resources that have a single author.
  class AuthorCell < Decidim::ViewModel
    include LayoutHelper
    include CellsHelper
    include ::Devise::Controllers::Helpers
    include ::Devise::Controllers::UrlHelpers
    include Messaging::ConversationHelper

    property :profile_path

    delegate :current_user, to: :controller, prefix: false

    def show
      render
    end

    def profile
      render
    end

    def profile_inline
      render
    end

    def date
      render
    end

    def flag
      render
    end

    def withdraw
      render
    end

    private

    def from_context_path
      resource_locator(from_context).path
    end

    def withdraw_path
      from_context_path + "/withdraw"
    end

    def creation_date?
      return true if posts_controller?
      return unless from_context
      return unless proposals_controller? || collaborative_drafts_controller?
      return unless show_action?
      true
    end

    def creation_date
      date_at = if proposals_controller?
                  from_context.published_at
                else
                  from_context.created_at
                end

      l date_at, format: :decidim_short
    end

    def commentable?
      return unless posts_controller?
      true
    end

    def author_classes
      (["author-data"] + options[:extra_classes].to_a).join(" ")
    end

    def actionable?
      return false if options[:has_actions] == false
      return true if user_author? && posts_controller?
      true if withdrawable? || flagable?
    end

    def user_author?
      true if "Decidim::UserPresenter".include? model.class.to_s
    end

    def profile_path?
      profile_path.present?
    end
  end
end
