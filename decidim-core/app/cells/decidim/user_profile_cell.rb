# frozen_string_literal: true

module Decidim
  # This cell renders the card of a user to show in followers and followed
  # lists.
  class UserProfileCell < Decidim::CardCell
    delegate :nickname, to: :presented_resource
    delegate :name, to: :presented_resource
    delegate :officialized?, to: :presented_resource
    delegate :badge, to: :presented_resource

    def user
      group_membership? ? model.user : model
    end

    def avatar
      present(user).avatar_url
    end

    def role
      return model.role if group_membership?
      return "admin" if user.admin?
    end

    def show_badge?
      user_group? ? badge.present? : officialized?
    end

    def resource_path
      # Exposes the same method, both Decidim::User and Decidim::UserGroup
      user.try(:profile_url) || decidim.profile_path(user.nickname)
    end

    def presented_resource
      @presented_resource ||= user.class.name.include?("Presenter") ? model : present(user)
    end
  end
end
