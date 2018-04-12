# frozen_string_literal: true

module Decidim
  module Admin
    module BulkActionsHelper
      # Renders an actions dropdown, including an item
      # for each bulk action.
      #
      # Returns a rendered dropdown.
      def bulk_actions_dropdown
        render partial: "decidim/admin/bulk_actions/dropdown"
      end

      # Renders a form to change the category of selected items
      #
      # Returns a rendered form.
      def bulk_action_recategorize
        render partial: "decidim/admin/bulk_actions/recategorize"
      end

      def proposal_find(id)
        Decidim::Proposals::Proposal.find(id)
      end
    end
  end
end
