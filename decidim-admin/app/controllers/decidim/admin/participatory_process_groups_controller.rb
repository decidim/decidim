# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ParticipatoryProcessGroupsController < ApplicationController
      helper_method :collection
      helper Decidim::OrganizationScopesHelper

      private

      def collection
        @collection ||= current_user.organization.participatory_process_groups
      end
    end
  end
end
