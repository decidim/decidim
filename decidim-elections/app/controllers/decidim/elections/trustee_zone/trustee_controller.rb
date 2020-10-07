# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # Exposes the trustee zone for trustee users
      class TrusteeController < ::Decidim::ApplicationController
        include Decidim::UserProfile

        helper_method :trustee

        def index
          enforce_permission_to :view, :trustee
        end

        private

        def trustee
          @trustee ||= Decidim::Elections::Trustee.for(current_user)
        end

        def permission_scope
          :trustee_zone
        end

        def permission_class_chain
          [
            Decidim::Elections::Permissions,
            Decidim::Permissions
          ]
        end
      end
    end
  end
end
