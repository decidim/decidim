# frozen_string_literal: true

module Decidim
  #
  # Decorator for user groups
  #
  class UserGroupPresenter < SimpleDelegator
    def nickname
      ""
    end

    def deleted?
      false
    end

    def badge_path
      return "" unless verified?

      "#{ActionController::Base.helpers.asset_path("decidim/icons.svg")}#icon-verified-badge"
    end

    def profile_path
      ""
    end

    delegate :url, to: :avatar, prefix: true
  end
end
