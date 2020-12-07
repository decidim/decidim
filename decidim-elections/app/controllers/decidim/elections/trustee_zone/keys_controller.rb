# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # Handles the KeyCeremony for trustee users
      class KeysController < ::Decidim::ApplicationController
        include Decidim::UserProfile

        helper_method :election, :trustee

        private

        def election
          # TODO: check permissions
          @election ||= Decidim::Elections::Election.find(params[:election_id])
        end

        def trustee
          @trustee ||= Decidim::Elections::Trustee.for(current_user)
        end
      end
    end
  end
end
