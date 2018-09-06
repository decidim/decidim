# frozen_string_literal: true

module Decidim
  # This cell renders the author of a resource. It is intended to be used
  # below resource titles to indicate its authorship & such, and is intended
  # for resources that have a single author.
  class AuthorCell < Decidim::ViewModel
    include LayoutHelper
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

    private

    def from_context
      options[:from].presence || context[:from].presence
    end

    def from_context_path
      resource_locator(from_context).path
    end

    def withdraw_path
      from_context_path + "/withdraw"
    end

    def withdrawable?
      return unless from_context
      return unless proposals_controller?
      return if index_action?
      from_context.withdrawable_by?(current_user)
    end

    def flagable?
      return unless from_context
      return unless proposals_controller? || debates_controller?
      return if index_action?
      return if from_context.official?
      true
    end

    def creation_date?
      return true if posts_controller?
      return unless from_context
      return unless proposals_controller?
      return unless show_action?
      true
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

    def proposals_controller?
      context[:controller].class.to_s == "Decidim::Proposals::ProposalsController"
    end

    def debates_controller?
      context[:controller].class.to_s == "Decidim::Debates::DebatesController"
    end

    def posts_controller?
      context[:controller].class.to_s == "Decidim::Blogs::PostsController"
    end

    def index_action?
      context[:controller].action_name == "index"
    end

    def show_action?
      context[:controller].action_name == "show"
    end

    def current_component
      from_context.component
    end

    def profile_path?
      profile_path.present?
    end
  end
end
