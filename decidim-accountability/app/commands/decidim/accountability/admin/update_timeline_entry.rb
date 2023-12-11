# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a TimelineEntry from the admin
      # panel.
      class UpdateTimelineEntry < Decidim::Commands::UpdateResource
        fetch_form_attributes :entry_date, :title, :description
      end
    end
  end
end
