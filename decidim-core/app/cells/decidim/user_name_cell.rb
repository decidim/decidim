# frozen_string_literal: true

module Decidim
  # This cell renders the name of a user.
  class UserNameCell < Decidim::CardCell
    delegate :name, to: :presented_resource

    def user
      group_membership? ? model.user : model
    end

    def avatar
      present(user).avatar_url(:thumb)
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
