# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Verifications
    module Admin
      module PendingAuthorizationLoader
        extend ActiveSupport::Concern

        included do
          def load_pending_authorization!(name, pending_authorization_id)
            Authorizations.new(organization: current_organization, name:, granted: false)
                          .query
                          .find(pending_authorization_id)
          end
        end
      end
    end
  end
end
