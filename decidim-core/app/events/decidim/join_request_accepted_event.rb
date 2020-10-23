# frozen-string_literal: true

module Decidim
  class JoinRequestAcceptedEvent < Decidim::Events::SimpleEvent
    delegate :url_helpers, to: "Decidim::Core::Engine.routes"

    i18n_attributes :user_group_name

    def resource_url
      url_helpers.profile_url(
        user_group_nickname,
        host: user.organization.host
      )
    end

    def resource_path
      url_helpers.profile_path(user_group_nickname)
    end

    def user_group_nickname
      extra["user_group_nickname"]
    end

    def user_group_name
      extra["user_group_name"]
    end
  end
end
