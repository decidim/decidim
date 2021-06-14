# frozen_string_literal: true

module Decidim
  module System
    class DashboardController < Decidim::System::ApplicationController
      before_action :check_organizations_presence

      def show
        @organizations = Organization.all
      end

      def check_organizations_presence
        return if Organization.exists?

        redirect_to new_organization_path
      end
    end
  end
end
