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

    def can_be_contacted?
      true
    end

    def officialization_text
      I18n.t("decidim.profiles.default_officialization_text_for_user_groups")
    end

    def can_follow?
      false
    end

    def members_count
      Decidim::UserGroups::AcceptedUsers.for(__getobj__).count
    end
  end
end
