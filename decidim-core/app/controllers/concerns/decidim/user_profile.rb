# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module UserProfile
    extend ActiveSupport::Concern

    include NeedsOrganization
    include FormFactory

    delegate :user_groups, to: :current_user, prefix: false

    included do
      layout "layouts/decidim/user_profile"

      helper_method :available_authorization_handlers,
                    :user_groups

      authorize_resource :current_user
    end

    def available_authorization_handlers
      Decidim.authorization_handlers
    end
  end
end
