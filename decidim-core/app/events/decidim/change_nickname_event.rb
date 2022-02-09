# frozen-string_literal: true

module Decidim
  class ChangeNicknameEvent < Decidim::Events::SimpleEvent
    include Decidim::Events::NotificationEvent
    delegate :organization, to: :user, prefix: false
    delegate :url_helpers, to: "Decidim::Core::Engine.routes"


    def notification_title
      ("<p><strong> Your nickname has been modified </strong></p> Go to your profile to see the modification").html_safe
    end

    def resource_path
      nil
    end

    def resource_title
      nil
    end
  end
end
