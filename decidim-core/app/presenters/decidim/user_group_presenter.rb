# frozen_string_literal: true

module Decidim
  #
  # Decorator for user groups
  #
  class UserGroupPresenter < UserPresenter
    def deleted?
      false
    end

    def badge
      return "" unless verified?

      "verified-badge"
    end

    delegate :url, to: :avatar, prefix: true

    def can_be_contacted?
      false
    end
  end
end
