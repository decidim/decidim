# frozen_string_literal: true

module Decidim
  # This cell renders the profile of the given user.
  class UserProfileCell < Decidim::CardMCell
    property :name
    property :officialized?

    def resource_path
      decidim.profile_path(model.nickname)
    end

    def nickname
      presented_resource.nickname
    end

    def badge
      presented_resource.badge
    end

    def description
      html_truncate(model.about.to_s, length: 100)
    end

    def avatar
      model.avatar_url(:big)
    end

    def presented_resource
      @presented_resource ||= present(model)
    end
  end
end
