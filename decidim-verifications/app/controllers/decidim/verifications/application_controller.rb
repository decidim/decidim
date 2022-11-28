# frozen_string_literal: true

module Decidim
  module Verifications
    class ApplicationController < Decidim::ApplicationController
      include NeedsPermission

      layout "layouts/decidim/authorizations"

      before_action :confirmed_user, only: [:new, :create, :renew]

      def new
        raise NotImplementedError
      end

      def create
        raise NotImplementedError
      end

      def renew
        raise NotImplementedError
      end

      private

      def confirmed_user
        return true if !current_user || (current_user && current_user.verifiable?)

        redirect_back(
          fallback_location: root_path,
          alert: t(
            "authorizations.create.unconfirmed",
            scope: "decidim.verifications"
          )
        ) && (return false)
      end
    end
  end
end
