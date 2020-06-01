# frozen-string_literal: true

module Decidim
  # To be used by UserGroup related events that trigger a notification to the administrators.
  class UserGroupAdminEvent < Decidim::Events::SimpleEvent
    delegate :url_helpers, to: "Decidim::Core::Engine.routes"

    i18n_attributes :user_group_name, :groups_admin_url, :groups_admin_path

    def resource_path
      url_helpers.profile_path(user_group_nickname)
    end

    def resource_url
      url_helpers.profile_url(
        user_group_nickname,
        host: user.organization.host
      )
    end

    def groups_admin_path
      Decidim::Admin::Engine.routes.url_helpers.user_groups_path
    end

    def groups_admin_url
      Decidim::Admin::Engine.routes.url_helpers.user_groups_url(host: user.organization.host)
    end

    def user_group_name
      resource.name
    end

    def user_group_nickname
      resource.nickname
    end
  end
end
