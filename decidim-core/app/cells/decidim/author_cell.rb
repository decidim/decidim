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
    include ERB::Util

    property :profile_path
    property :can_be_contacted?
    property :has_tooltip?

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
      return decidim.withdraw_amend_path(from_context.amendment) if from_context.emendation?

      from_context_path + "/withdraw"
    end

    def creation_date?
      from_context.respond_to?(:published_at) || from_context.respond_to?(:created_at)

      true
    end

    def creation_date
      date_at = from_context.try(:published_at) || from_context.try(:created_at)

      l date_at, format: :decidim_short
    end

    def commentable?
      return unless posts_controller?

      true
    end

    def endorsable?
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
      return false if options[:skip_profile_link] == true

      profile_path.present?
    end

    def raw_model
      model.try(:__getobj__) || model
    end
  end
end
