# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # The UserProfile concern must be included in all the controllers
  # that are shown in the user's profile settings. It adds the
  # proper layout, as well as helper methods that help render the
  # side menu, amongst others.
  module UserProfile
    extend ActiveSupport::Concern
    include FormFactory
    include HasAccountBreadcrumb

    included do
      helper Decidim::UserProfileHelper
      layout "layouts/decidim/user_profile"

      helper_method :available_verification_workflows

      before_action :current_user
      before_action do
        enforce_permission_to :update_profile, :user, current_user:
      end
    end

    # Public: Available authorization handlers in order to conditionally
    # show the menu element.
    def available_verification_workflows
      Verifications::Adapter.from_collection(
        current_organization.available_authorizations & Decidim.authorization_workflows.map(&:name)
      )
    end
  end
end
