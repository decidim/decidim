# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a TimelineEntry
      # for a Result from the admin panel.
      class CreateTimelineEntry < Decidim::Commands::CreateResource
        fetch_form_attributes :decidim_accountability_result_id, :entry_date, :title, :description

        protected

        def resource_class = Decidim::Accountability::TimelineEntry
      end
    end
  end
end
