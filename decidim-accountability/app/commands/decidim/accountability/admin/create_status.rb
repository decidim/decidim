# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a Status from the admin
      # panel.
      class CreateStatus < Decidim::Commands::CreateResource
        fetch_form_attributes :key, :name, :description, :progress, :component

        protected

        def resource_class = Decidim::Accountability::Status
      end
    end
  end
end
