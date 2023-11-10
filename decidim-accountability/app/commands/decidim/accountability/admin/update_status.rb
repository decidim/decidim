# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a Result from the admin
      # panel.
      class UpdateStatus < Decidim::Commands::UpdateResource
        fetch_form_attributes :key, :name, :description, :progress
      end
    end
  end
end
