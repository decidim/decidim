# frozen-string_literal: true

module Decidim
  module Elections
    module Trustees
      class NotifyNewTrusteeEvent < Decidim::Events::SimpleEvent
        # This event sends a notification when a new trustee gets created.

        delegate :organization, to: :user, prefix: false
        delegate :url_helpers, to: "Decidim::Core::Engine.routes"

        i18n_attributes :resource_name, :trustee_zone_url

        def resource_name
          @resource_name ||= translated_attribute(participatory_space.title)
        end

        def participatory_space
          @participatory_space ||= resource
        end

        def trustee_zone_url
          url_helpers.decidim_elections_trustee_zone_url(host: organization.host)
        end
      end
    end
  end
end
