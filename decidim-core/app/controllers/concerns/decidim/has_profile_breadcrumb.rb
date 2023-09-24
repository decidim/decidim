# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Include this concern in controllers associated with profile to insert the
  # corresponding element breadcrumb
  module HasProfileBreadcrumb
    extend ActiveSupport::Concern

    included do
      include HasSpecificBreadcrumb

      private

      def breadcrumb_item
        {
          label: t("layouts.decidim.user_profile.profile"),
          active: true
        }
      end
    end
  end
end
