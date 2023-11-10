# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a Result from the admin
      # panel.
      class CreateImportedResult < Decidim::Commands::CreateResource
        include Decidim::Accountability::ResultCommandHelper

        fetch_form_attributes :scope, :component, :category, :parent_id, :title, :description, :start_date,
                              :end_date, :progress, :decidim_accountability_status_id, :external_id, :weight

        def initialize(form, parent_id = nil)
          super(form)
          @parent_id = parent_id
        end

        private

        attr_reader :parent_id
        alias result resource

        def resource_class = Decidim::Accountability::Result

        def extra_params = { visibility: "all" }

        def attributes = super.merge(parent_id:)

        def run_after_hooks
          link_meetings
          link_proposals
          link_projects
          notify_proposal_followers
        end
      end
    end
  end
end
