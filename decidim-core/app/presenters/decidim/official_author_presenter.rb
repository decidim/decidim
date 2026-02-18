# frozen_string_literal: true

module Decidim
  #
  # A dummy presenter to abstract out the author of an official resource.
  #
  class OfficialAuthorPresenter
    def name
      I18n.t("decidim.author.official_author")
    end

    def nickname
      ""
    end

    def badge
      ""
    end

    def profile_path
      ""
    end

    def profile_url
      ""
    end

    def avatar_url(_variant = nil)
      ActionController::Base.helpers.asset_pack_path("media/images/default-avatar.svg")
    end

    def deleted?
      false
    end

    def can_be_contacted?
      false
    end
  end
end
