# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user creates a CollaborativeText from the admin
      # panel.
      class CreateCollaborativeText < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :component

        private

        def resource_class = Decidim::CollaborativeTexts::Document
      end
    end
  end
end
