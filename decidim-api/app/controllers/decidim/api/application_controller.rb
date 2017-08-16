# frozen_string_literal: true

module Decidim
  module Api
    # Base controller for `decidim-api`. All other controllers inherit from this.
    class ApplicationController < ::DecidimController
      skip_before_action :verify_authenticity_token
      include NeedsOrganization
      include NeedsAuthorization
      include ImpersonateUsers

      # Overwrites `cancancan`'s method to point to the correct ability class,
      # since the gem expects the ability class to be in the root namespace.
      def current_ability_klass
        Decidim::Abilities::BaseAbility
      end
    end
  end
end
