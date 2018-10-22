# frozen_string_literal: true

module Decidim
  # This cell renders the profile of the given user.
  class UserProfileCell < Decidim::CardMCell
    def user
      model
    end

    def resource_path
      decidim.profile_path(user.nickname)
    end

    delegate :nickname, to: :presented_resource
    delegate :name, to: :presented_resource
    delegate :officialized?, to: :presented_resource

    delegate :badge, to: :presented_resource

    def description
      html_truncate(user.about.to_s, length: 100)
    end

    def avatar
      user.avatar_url(:big)
    end

    def presented_resource
      @presented_resource ||= user.class.name.include?("Presenter") ? model : present(user)
    end
  end
end
