# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Include this concern in controllers associated with own account to insert the
  # corresponding element breadcrumb
  module HasAccountBreadcrumb
    extend ActiveSupport::Concern

    included do
      include HasSpecificBreadcrumb

      private

      def breadcrumb_item
        {
          label: t("layouts.decidim.user_menu.profile"),
          active: true
        }
      end
    end
  end
end
