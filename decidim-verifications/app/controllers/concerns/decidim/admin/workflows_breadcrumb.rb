# frozen_string_literal: true

module Decidim
  module Admin
    # This module contains the breadcrumb for the verifications workflows
    module WorkflowsBreadcrumb
      extend ActiveSupport::Concern

      included do
        helper_method :context_breadcrumb_items
      end

      private

      def context_breadcrumb_items
        @context_breadcrumb_items ||= [authorization_breadcrumb_item]
      end

      def authorization_breadcrumb_item
        {
          label: I18n.t("menu.authorization_workflows", scope: "decidim.admin"),
          url: decidim_admin.authorization_workflows_path,
          active: true
        }
      end
    end
  end
end
