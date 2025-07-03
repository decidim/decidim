# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a Milestone
      # for a Result from the admin panel.
      class CreateMilestone < Decidim::Commands::CreateResource
        fetch_form_attributes :decidim_accountability_result_id, :entry_date, :title, :description

        private

        def resource_class = Decidim::Accountability::Milestone
      end
    end
  end
end
