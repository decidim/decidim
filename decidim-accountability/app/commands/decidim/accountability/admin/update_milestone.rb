# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a Milestone from the admin
      # panel.
      class UpdateMilestone < Decidim::Commands::UpdateResource
        fetch_form_attributes :entry_date, :title, :description
      end
    end
  end
end
