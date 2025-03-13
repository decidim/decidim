# frozen_string_literal: true

module Decidim
  # This cell renders the card of a user to show in followers and followed
  # lists.
  class UserProfileCell < Decidim::CardCell
    delegate :nickname, to: :presented_resource
    delegate :name, to: :presented_resource
    delegate :officialized?, to: :presented_resource
    delegate :badge, to: :presented_resource

    alias user model

    def avatar
      present(user).avatar_url
    end

    def role
      return "admin" if user.admin?
    end

    def resource_path
      user.try(:profile_url) || decidim.profile_path(user.nickname)
    end

    def presented_resource
      @presented_resource ||= user.class.name.include?("Presenter") ? model : present(user)
    end
  end
end
