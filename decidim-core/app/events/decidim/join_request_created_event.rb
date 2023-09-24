# frozen_string_literal: true

module Decidim
  class JoinRequestCreatedEvent < Decidim::Events::SimpleEvent
    delegate :url_helpers, to: "Decidim::Core::Engine.routes"

    i18n_attributes :user_group_name

    def resource_url
      url_helpers.profile_group_members_url(
        user_group_nickname,
        host: user.organization.host
      )
    end

    def resource_path
      url_helpers.profile_group_members_path(user_group_nickname)
    end

    def user_group_nickname
      extra["user_group_nickname"]
    end

    def user_group_name
      extra["user_group_name"]
    end
  end
end
